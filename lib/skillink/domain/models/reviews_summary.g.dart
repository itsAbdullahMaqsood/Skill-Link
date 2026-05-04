// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewUserSummary _$ReviewUserSummaryFromJson(Map<String, dynamic> json) =>
    _ReviewUserSummary(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      profilePic: json['profilePic'] as String?,
      ratings: (json['ratings'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ReviewUserSummaryToJson(_ReviewUserSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'profilePic': instance.profilePic,
      'ratings': instance.ratings,
      'reviewCount': instance.reviewCount,
    };

_ReviewsSummary _$ReviewsSummaryFromJson(Map<String, dynamic> json) =>
    _ReviewsSummary(
      user: ReviewUserSummary.fromJson(json['user'] as Map<String, dynamic>),
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Review>[],
    );

Map<String, dynamic> _$ReviewsSummaryToJson(_ReviewsSummary instance) =>
    <String, dynamic>{'user': instance.user, 'reviews': instance.reviews};
