import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/posted_job_repository.dart';
import 'package:skilllink/skillink/domain/models/job_media_type.dart';
import 'package:skilllink/skillink/domain/models/job_post_tag.dart';
import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

class PostJobMediaItem {
  const PostJobMediaItem({
    required this.localPath,
    required this.type,
    this.thumbnailPath,
    this.cachedBytes,
  });

  final String localPath;
  final JobMediaType type;
  final String? thumbnailPath;

  final int? cachedBytes;
}

class PostJobState {
  const PostJobState({
    this.title = '',
    this.tag = JobPostTag.electrician,
    this.descriptionText = '',
    this.descriptionVoiceLocalPath,
    this.media = const <PostJobMediaItem>[],
    this.street = '',
    this.area = '',
    this.city = '',
    this.postalCode = '',
    this.isPosting = false,
    this.uploadProgress,
    this.errorMessage,
    this.useVoiceDescription = false,
  });

  final String title;
  final JobPostTag tag;
  final String descriptionText;
  final String? descriptionVoiceLocalPath;
  final List<PostJobMediaItem> media;
  final String street;
  final String area;
  final String city;
  final String postalCode;
  final bool isPosting;
  final double? uploadProgress;
  final String? errorMessage;
  final bool useVoiceDescription;

  int get estimatedMediaBytes {
    var total = 0;
    for (final m in media) {
      total += m.cachedBytes ?? 0;
    }
    return total;
  }

  bool get mediaSizeWarning =>
      estimatedMediaBytes > AppConstants.postedJobMediaSoftTotalBytes;

  PostJobState copyWith({
    String? title,
    JobPostTag? tag,
    String? descriptionText,
    String? descriptionVoiceLocalPath,
    bool clearVoice = false,
    List<PostJobMediaItem>? media,
    String? street,
    String? area,
    String? city,
    String? postalCode,
    bool? isPosting,
    double? uploadProgress,
    String? errorMessage,
    bool clearError = false,
    bool? useVoiceDescription,
  }) {
    return PostJobState(
      title: title ?? this.title,
      tag: tag ?? this.tag,
      descriptionText: descriptionText ?? this.descriptionText,
      descriptionVoiceLocalPath: clearVoice
          ? null
          : (descriptionVoiceLocalPath ?? this.descriptionVoiceLocalPath),
      media: media ?? this.media,
      street: street ?? this.street,
      area: area ?? this.area,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      isPosting: isPosting ?? this.isPosting,
      uploadProgress: uploadProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      useVoiceDescription: useVoiceDescription ?? this.useVoiceDescription,
    );
  }
}

class PostJobViewModel extends StateNotifier<PostJobState> {
  PostJobViewModel(this._ref, {PostedJob? editJob})
      : _editJobId = editJob?.jobId,
        _seedEdit = editJob,
        super(
          PostJobState(
            title: editJob?.title ?? '',
            tag: editJob?.tag ?? JobPostTag.electrician,
            descriptionText: editJob?.descriptionText ?? '',
            descriptionVoiceLocalPath: null,
            media: editJob == null
                ? const <PostJobMediaItem>[]
                : [
                    for (final m in editJob.media)
                      PostJobMediaItem(
                        localPath: m.url,
                        type: m.type,
                        thumbnailPath: m.thumbnailUrl,
                      ),
                  ],
            street: editJob?.location.street ?? '',
            area: editJob?.location.area ?? '',
            city: editJob?.location.city ?? '',
            postalCode: editJob?.location.postalCode ?? '',
          ),
        ) {
    if (editJob == null) {
      final u = _ref.read(authViewModelProvider).user;
      if (u != null) {
        state = PostJobState(
          title: state.title,
          tag: state.tag,
          descriptionText: state.descriptionText,
          media: state.media,
          street: u.address.street,
          area: u.address.area,
          city: u.address.city,
          postalCode: u.address.postalCode,
        );
      }
    }
  }

  final Ref _ref;
  final String? _editJobId;
  final PostedJob? _seedEdit;

  String? _draftJobIdCache;
  String get _draftJobId => _editJobId ??
      (_draftJobIdCache ??=
          'draft_${DateTime.now().millisecondsSinceEpoch}_${identityHashCode(this) & 0xffff}');

  String _newStorageKey() =>
      '${DateTime.now().microsecondsSinceEpoch}_${DateTime.now().hashCode & 0xffff}';

  void setTitle(String v) => state = state.copyWith(title: v);
  void setTag(JobPostTag v) => state = state.copyWith(tag: v);
  void setDescriptionText(String v) => state = state.copyWith(descriptionText: v);
  void setUseVoice(bool v) => state = state.copyWith(useVoiceDescription: v);
  void setVoicePath(String? path, {bool clear = false}) =>
      state = state.copyWith(descriptionVoiceLocalPath: path, clearVoice: clear);

  void setStreet(String v) => state = state.copyWith(street: v);
  void setArea(String v) => state = state.copyWith(area: v);
  void setCity(String v) => state = state.copyWith(city: v);
  void setPostal(String v) => state = state.copyWith(postalCode: v);

  Future<void> addMedia(PostJobMediaItem item) async {
    var enriched = item;
    if (item.cachedBytes == null && !item.localPath.startsWith('http')) {
      try {
        final size = await File(item.localPath).length();
        enriched = PostJobMediaItem(
          localPath: item.localPath,
          type: item.type,
          thumbnailPath: item.thumbnailPath,
          cachedBytes: size,
        );
      } on Exception {
      }
    }
    if (!mounted) return;
    state = state.copyWith(media: [...state.media, enriched]);
  }

  void removeMediaAt(int index) {
    final next = [...state.media]..removeAt(index);
    state = state.copyWith(media: next);
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<bool> submit() async {
    final user = _ref.read(authViewModelProvider).user;
    if (user == null) {
      state = state.copyWith(errorMessage: 'You must be signed in.');
      return false;
    }
    final t = state.title.trim();
    if (t.isEmpty || t.length > AppConstants.maxPostedJobTitleLength) {
      state = state.copyWith(errorMessage: 'Please enter a valid title.');
      return false;
    }
    if (!state.useVoiceDescription) {
      if (state.descriptionText.trim().length >
          AppConstants.maxPostedJobDescriptionLength) {
        state = state.copyWith(errorMessage: 'Description is too long.');
        return false;
      }
      if (state.descriptionText.trim().isEmpty &&
          state.descriptionVoiceLocalPath == null) {
        state = state.copyWith(
          errorMessage: 'Add a typed description or a voice note.',
        );
        return false;
      }
    } else {
      if (state.descriptionVoiceLocalPath == null) {
        state = state.copyWith(errorMessage: 'Record a voice note.');
        return false;
      }
    }
    if (state.street.trim().isEmpty ||
        state.area.trim().isEmpty ||
        state.city.trim().isEmpty ||
        state.postalCode.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please complete the address.');
      return false;
    }

    state = state.copyWith(isPosting: true, clearError: true, uploadProgress: 0);

    final upload = _ref.read(mediaUploadServiceProvider);
    final uid = user.id;
    String? voiceUrl;
    if (state.descriptionVoiceLocalPath != null) {
      final f = File(state.descriptionVoiceLocalPath!);
      final voiceSize = await f.length();
      if (!mounted) return false;
      if (voiceSize > AppConstants.maxVoiceNoteSizeBytes) {
        state = state.copyWith(
          isPosting: false,
          errorMessage: 'Voice note exceeds the size limit.',
        );
        return false;
      }
      final path = 'users/$uid/voice-notes/${_newStorageKey()}.m4a';
      final up = await upload.uploadFile(
        storagePath: path,
        file: f,
        contentType: 'audio/mp4',
        onProgress: (p) {
          if (!mounted) return;
          state = state.copyWith(uploadProgress: p * 0.3);
        },
      );
      if (!mounted) return false;
      if (up.isFailure) {
        state = state.copyWith(
          isPosting: false,
          errorMessage: up.errorOrNull ?? 'Voice upload failed.',
        );
        return false;
      }
      voiceUrl = up.valueOrNull;
    }

    final tempJobId = _draftJobId;

    var missing = 0;
    for (final m in state.media) {
      if (m.localPath.startsWith('http')) continue;
      if (!await File(m.localPath).exists()) missing += 1;
    }
    if (!mounted) return false;
    if (missing > 0) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: missing == 1
            ? 'One attachment is no longer available on the device. Remove it (or re-attach it) and try again.'
            : '$missing attachments are no longer available on the device. Remove them (or re-attach them) and try again.',
      );
      return false;
    }

    final mediaOut = <JobMedia>[];
    state = state.copyWith(uploadProgress: 0.3);

    final uploadable = state.media
        .where((m) => !m.localPath.startsWith('http'))
        .length;
    var indexInBatch = 0;

    for (final m in state.media) {
      if (m.localPath.startsWith('http')) {
        mediaOut.add(
          JobMedia(
            url: m.localPath,
            type: m.type,
            thumbnailUrl: m.thumbnailPath,
          ),
        );
        continue;
      }
      final file = File(m.localPath);
      if (!mounted) return false;
      final ext = m.type == JobMediaType.video ? 'mp4' : 'jpg';
      final path = 'jobs/$tempJobId/media/${_newStorageKey()}.$ext';
      final contentType =
          m.type == JobMediaType.video ? 'video/mp4' : 'image/jpeg';
      final slot = indexInBatch;
      final res = await upload.uploadFile(
        storagePath: path,
        file: file,
        contentType: contentType,
        onProgress: (p) {
          if (!mounted) return;
          final perItem = uploadable > 0 ? 0.65 / uploadable : 0.65;
          final v = 0.3 + (slot + p.clamp(0.0, 1.0)) * perItem;
          state = state.copyWith(uploadProgress: v.clamp(0.0, 0.95));
        },
      );
      if (!mounted) return false;
      if (res.isFailure) {
        state = state.copyWith(
          isPosting: false,
          errorMessage: res.errorOrNull ?? 'Media upload failed.',
        );
        return false;
      }
      indexInBatch += 1;
      mediaOut.add(
        JobMedia(
          url: res.valueOrNull!,
          type: m.type,
          thumbnailUrl: m.thumbnailPath,
        ),
      );
    }

    final address = StructuredAddress(
      street: state.street.trim(),
      area: state.area.trim(),
      city: state.city.trim(),
      postalCode: state.postalCode.trim(),
    );

    final repo = _ref.read(postedJobRepositoryProvider);
    final firstName =
        user.name.trim().split(RegExp(r'\s+')).firstWhere((s) => s.isNotEmpty, orElse: () => 'Homeowner');

    if (_editJobId != null) {
      final existing = _seedEdit;
      if (existing == null) {
        state = state.copyWith(isPosting: false, errorMessage: 'Post not found.');
        return false;
      }
      final updated = existing.copyWith(
        title: t,
        tag: state.tag,
        descriptionText: state.useVoiceDescription
            ? null
            : state.descriptionText.trim(),
        descriptionVoiceUrl: voiceUrl ?? existing.descriptionVoiceUrl,
        media: mediaOut,
        location: address,
        locationLat: existing.locationLat,
        locationLng: existing.locationLng,
      );
      final r = await repo.updatePostedJob(updated);
      if (!mounted) return false;
      if (r.isFailure) {
        state = state.copyWith(
          isPosting: false,
          errorMessage: r.errorOrNull ?? 'Could not update.',
        );
        return false;
      }
      state = state.copyWith(isPosting: false, uploadProgress: 1);
      return true;
    }

    final payload = CreatePostedJobPayload(
      homeownerId: uid,
      homeownerDisplayName: firstName,
      title: t,
      tag: state.tag,
      descriptionText:
          state.useVoiceDescription ? null : state.descriptionText.trim(),
      descriptionVoiceUrl: voiceUrl,
      media: mediaOut,
      location: address,
      locationLat: AppConstants.defaultPostedJobLat,
      locationLng: AppConstants.defaultPostedJobLng,
    );
    final created = await repo.createPostedJob(payload);
    if (!mounted) return false;
    if (created.isFailure) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: created.errorOrNull ?? 'Could not post.',
      );
      return false;
    }
    state = state.copyWith(isPosting: false, uploadProgress: 1);
    return true;
  }
}

final postJobViewModelProvider = StateNotifierProvider.autoDispose
    .family<PostJobViewModel, PostJobState, PostedJob?>((ref, edit) {
  return PostJobViewModel(ref, editJob: edit);
});
