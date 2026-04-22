// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  address: StructuredAddress.fromJson(json['address'] as Map<String, dynamic>),
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  avatarUrl: json['avatarUrl'] as String?,
  cnicNumber: json['cnicNumber'] as String? ?? '',
  cnicFrontUrl: json['cnicFrontUrl'] as String? ?? '',
  cnicBackUrl: json['cnicBackUrl'] as String? ?? '',
  profileComplete: json['profileComplete'] as bool? ?? true,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'role': _$UserRoleEnumMap[instance.role]!,
  'avatarUrl': instance.avatarUrl,
  'cnicNumber': instance.cnicNumber,
  'cnicFrontUrl': instance.cnicFrontUrl,
  'cnicBackUrl': instance.cnicBackUrl,
  'profileComplete': instance.profileComplete,
};

const _$UserRoleEnumMap = {
  UserRole.homeowner: 'homeowner',
  UserRole.worker: 'worker',
};
