// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posted_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JobMedia _$JobMediaFromJson(Map<String, dynamic> json) => _JobMedia(
  url: json['url'] as String,
  type: json['type'] == null
      ? JobMediaType.photo
      : _jobMediaTypeFromJson(json['type']),
  thumbnailUrl: json['thumbnailUrl'] as String?,
);

Map<String, dynamic> _$JobMediaToJson(_JobMedia instance) => <String, dynamic>{
  'url': instance.url,
  'type': _jobMediaTypeToJson(instance.type),
  'thumbnailUrl': instance.thumbnailUrl,
};

_PostedJob _$PostedJobFromJson(Map<String, dynamic> json) => _PostedJob(
  jobId: json['jobId'] as String,
  homeownerId: json['homeownerId'] as String,
  title: json['title'] as String,
  tag: _postedJobTagFromJson(json['tag']),
  descriptionText: json['descriptionText'] as String?,
  descriptionVoiceUrl: json['descriptionVoiceUrl'] as String?,
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => JobMedia.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <JobMedia>[],
  location: StructuredAddress.fromJson(
    json['location'] as Map<String, dynamic>,
  ),
  locationLat: (json['locationLat'] as num).toDouble(),
  locationLng: (json['locationLng'] as num).toDouble(),
  status: json['status'] == null
      ? PostedJobStatus.open
      : _postedJobStatusFromJson(json['status']),
  acceptedBidId: json['acceptedBidId'] as String?,
  acceptedWorkerId: json['acceptedWorkerId'] as String?,
  trackingJobId: json['trackingJobId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  acceptedAt: json['acceptedAt'] == null
      ? null
      : DateTime.parse(json['acceptedAt'] as String),
  homeownerDisplayName: json['homeownerDisplayName'] as String?,
);

Map<String, dynamic> _$PostedJobToJson(_PostedJob instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'homeownerId': instance.homeownerId,
      'title': instance.title,
      'tag': _postedJobTagToJson(instance.tag),
      'descriptionText': instance.descriptionText,
      'descriptionVoiceUrl': instance.descriptionVoiceUrl,
      'media': instance.media,
      'location': instance.location,
      'locationLat': instance.locationLat,
      'locationLng': instance.locationLng,
      'status': _postedJobStatusToJson(instance.status),
      'acceptedBidId': instance.acceptedBidId,
      'acceptedWorkerId': instance.acceptedWorkerId,
      'trackingJobId': instance.trackingJobId,
      'createdAt': instance.createdAt.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'homeownerDisplayName': instance.homeownerDisplayName,
    };
