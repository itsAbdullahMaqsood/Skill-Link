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
  reviewerName: json['reviewerName'] as String?,
);

Map<String, dynamic> _$ReviewToJson(_Review instance) => <String, dynamic>{
  'id': instance.id,
  'jobId': instance.jobId,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'reviewerName': instance.reviewerName,
};
