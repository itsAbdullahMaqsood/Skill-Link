// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skilllink/skillink/domain/models/job_media_type.dart';
import 'package:skilllink/skillink/domain/models/job_post_tag.dart';
import 'package:skilllink/skillink/domain/models/posted_job_status.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';

part 'posted_job.freezed.dart';
part 'posted_job.g.dart';

JobPostTag _postedJobTagFromJson(Object? json) =>
    JobPostTagX.parse(json as String?);

String _postedJobTagToJson(JobPostTag t) => t.wireName;

PostedJobStatus _postedJobStatusFromJson(Object? json) =>
    PostedJobStatusX.parse(json as String?);

String _postedJobStatusToJson(PostedJobStatus s) => s.wireName;

JobMediaType _jobMediaTypeFromJson(Object? json) =>
    JobMediaTypeX.parse(json as String?);

String _jobMediaTypeToJson(JobMediaType t) => t.wireName;

@freezed
abstract class JobMedia with _$JobMedia {
  const factory JobMedia({
    required String url,
    @JsonKey(fromJson: _jobMediaTypeFromJson, toJson: _jobMediaTypeToJson)
    @Default(JobMediaType.photo)
    JobMediaType type,
    String? thumbnailUrl,
  }) = _JobMedia;

  factory JobMedia.fromJson(Map<String, dynamic> json) =>
      _$JobMediaFromJson(json);
}

@freezed
abstract class PostedJob with _$PostedJob {
  const factory PostedJob({
    required String jobId,
    required String homeownerId,
    required String title,
    @JsonKey(fromJson: _postedJobTagFromJson, toJson: _postedJobTagToJson)
    required JobPostTag tag,
    String? descriptionText,
    String? descriptionVoiceUrl,
    @Default(<JobMedia>[]) List<JobMedia> media,
    required StructuredAddress location,
    required double locationLat,
    required double locationLng,
    @JsonKey(fromJson: _postedJobStatusFromJson, toJson: _postedJobStatusToJson)
    @Default(PostedJobStatus.open)
    PostedJobStatus status,
    String? acceptedBidId,
    String? acceptedWorkerId,
    String? trackingJobId,
    required DateTime createdAt,
    DateTime? acceptedAt,
    String? homeownerDisplayName,
  }) = _PostedJob;

  factory PostedJob.fromJson(Map<String, dynamic> json) =>
      _$PostedJobFromJson(json);
}
