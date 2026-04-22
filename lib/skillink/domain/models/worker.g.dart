// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Worker _$WorkerFromJson(Map<String, dynamic> json) => _Worker(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  skillTypes: (json['skillTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  rating: (json['rating'] as num).toDouble(),
  reviewCount: (json['reviewCount'] as num).toInt(),
  verificationStatus: json['verificationStatus'] as bool,
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
  role: json['role'] as String?,
  accountStatus: json['accountStatus'] as String?,
  experienceNote: json['experienceNote'] as String?,
);

Map<String, dynamic> _$WorkerToJson(_Worker instance) => <String, dynamic>{
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
  'role': instance.role,
  'accountStatus': instance.accountStatus,
  'experienceNote': instance.experienceNote,
};
