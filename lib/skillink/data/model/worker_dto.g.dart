// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkerDto _$WorkerDtoFromJson(Map<String, dynamic> json) => _WorkerDto(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  skillTypes:
      (json['skillTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  verificationStatus: json['verificationStatus'] as bool? ?? false,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
  avatarUrl: json['avatarUrl'] as String?,
  bio: json['bio'] as String?,
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  portfolioUrls:
      (json['portfolioUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  experienceYears: (json['experienceYears'] as num?)?.toInt(),
  serviceRadiusKm: (json['serviceRadiusKm'] as num?)?.toDouble(),
);

Map<String, dynamic> _$WorkerDtoToJson(_WorkerDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'skillTypes': instance.skillTypes,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'verificationStatus': instance.verificationStatus,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'hourlyRate': instance.hourlyRate,
      'avatarUrl': instance.avatarUrl,
      'bio': instance.bio,
      'distanceKm': instance.distanceKm,
      'portfolioUrls': instance.portfolioUrls,
      'experienceYears': instance.experienceYears,
      'serviceRadiusKm': instance.serviceRadiusKm,
    };
