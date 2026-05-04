// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Review _$ReviewFromJson(Map<String, dynamic> json) => _Review(
  id: json['id'] as String,
  jobId: json['jobId'] as String,
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  reviewerId: json['reviewerId'] as String?,
  revieweeId: json['revieweeId'] as String?,
  serviceRequestId: json['serviceRequestId'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReviewToJson(_Review instance) => <String, dynamic>{
  'id': instance.id,
  'jobId': instance.jobId,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'reviewerId': instance.reviewerId,
  'revieweeId': instance.revieweeId,
  'serviceRequestId': instance.serviceRequestId,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
