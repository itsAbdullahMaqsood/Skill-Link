import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/domain/models/job_media_type.dart';
import 'package:skilllink/skillink/domain/models/job_post_tag.dart';
import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/post_job/view_models/post_job_view_model.dart';
import 'package:skilllink/skillink/ui/post_job/widgets/voice_note_recorder.dart';
import 'package:skilllink/skillink/utils/text_format.dart';

class PostJobSheet extends ConsumerStatefulWidget {
  const PostJobSheet({super.key, this.editJob});

  final PostedJob? editJob;

  @override
  ConsumerState<PostJobSheet> createState() => _PostJobSheetState();
}

class _PostJobSheetState extends ConsumerState<PostJobSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _street = TextEditingController();
  final _area = TextEditingController();
  final _city = TextEditingController();
  final _postal = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final seed = ref.read(postJobViewModelProvider(widget.editJob));
    _title.text = seed.title;
    _desc.text = seed.descriptionText;
    _street.text = seed.street;
    _area.text = seed.area;
    _city.text = seed.city;
    _postal.text = seed.postalCode;
  }

  @override
  void dispose() {
    _tabs.dispose();
    _title.dispose();
    _desc.dispose();
    _street.dispose();
    _area.dispose();
    _city.dispose();
    _postal.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(PostJobViewModel vm) async {
    try {
      final f = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (f == null) return;
      await vm.addMedia(
        PostJobMediaItem(localPath: f.path, type: JobMediaType.photo),
      );
    } on Exception catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the photo picker.')),
      );
    }
  }

  Future<void> _pickVideo(PostJobViewModel vm) async {
    try {
      final f = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: AppConstants.maxVideoDuration,
      );
      if (f == null) return;
      await vm.addMedia(
        PostJobMediaItem(localPath: f.path, type: JobMediaType.video),
      );
    } on Exception catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the video picker.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(postJobViewModelProvider(widget.editJob).notifier);
    final st = ref.watch(postJobViewModelProvider(widget.editJob));

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  children: [
                    Text(
                      widget.editJob == null ? 'Post a job' : 'Edit post',
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _title,
                      label: 'Title',
                      onChanged: vm.setTitle,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<JobPostTag>(
                      // ignore: deprecated_member_use
                      value: st.tag,
                      decoration: const InputDecoration(labelText: 'Trade'),
                      items: JobPostTag.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(TextFormat.trade(t.serviceTypeSlug)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) vm.setTag(v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TabBar(
                      controller: _tabs,
                      tabs: const [
                        Tab(text: 'Typed'),
                        Tab(text: 'Voice'),
                      ],
                      onTap: (index) {
                        if (index == 0) vm.setUseVoice(false);
                      },
                    ),
                    SizedBox(
                      height: 180,
                      child: TabBarView(
                        controller: _tabs,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: AppTextField(
                              controller: _desc,
                              label: 'Description',
                              maxLines: 6,
                              onChanged: vm.setDescriptionText,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: VoiceNoteRecorder(
                              onPath: (p) {
                                vm.setUseVoice(true);
                                vm.setVoicePath(p);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Media', style: AppTypography.labelLarge),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Photo',
                          onPressed: () => unawaited(_pickPhoto(vm)),
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                        ),
                        IconButton(
                          tooltip: 'Video (max 2 min)',
                          onPressed: () => unawaited(_pickVideo(vm)),
                          icon: const Icon(Icons.video_call_outlined),
                        ),
                      ],
                    ),
                    if (st.mediaSizeWarning)
                      Text(
                        'Selected media is over 200 MB — upload may fail.',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.warning),
                      ),
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: st.media.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final m = st.media[i];
                          return Stack(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.border,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  m.type == JobMediaType.video
                                      ? Icons.videocam_outlined
                                      : Icons.image_outlined,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => vm.removeMediaAt(i),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Location', style: AppTypography.labelLarge),
                    AppTextField(
                      controller: _street,
                      label: 'Street',
                      onChanged: vm.setStreet,
                    ),
                    AppTextField(
                      controller: _area,
                      label: 'Area',
                      onChanged: vm.setArea,
                    ),
                    AppTextField(
                      controller: _city,
                      label: 'City',
                      onChanged: vm.setCity,
                    ),
                    AppTextField(
                      controller: _postal,
                      label: 'Postal code',
                      onChanged: vm.setPostal,
                    ),
                    if (st.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          st.errorMessage!,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.danger),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  20 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: PrimaryButton(
                  label: widget.editJob == null ? 'Post' : 'Save',
                  isLoading: st.isPosting,
                  onPressed: () async {
                    vm.setTitle(_title.text);
                    vm.setDescriptionText(_desc.text);
                    vm.setStreet(_street.text);
                    vm.setArea(_area.text);
                    vm.setCity(_city.text);
                    vm.setPostal(_postal.text);
                    final ok = await vm.submit();
                    if (ok && context.mounted) Navigator.pop(context, true);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
