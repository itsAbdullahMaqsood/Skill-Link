// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  role: json['role'] as String?,
  address: json['address'] as Map<String, dynamic>?,
  avatarUrl: json['avatarUrl'] as String?,
  cnicNumber: json['cnicNumber'] as String? ?? '',
  cnicFrontUrl: json['cnicFrontUrl'] as String? ?? '',
  cnicBackUrl: json['cnicBackUrl'] as String? ?? '',
  profileComplete: json['profileComplete'] as bool? ?? true,
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'role': instance.role,
  'address': instance.address,
  'avatarUrl': instance.avatarUrl,
  'cnicNumber': instance.cnicNumber,
  'cnicFrontUrl': instance.cnicFrontUrl,
  'cnicBackUrl': instance.cnicBackUrl,
  'profileComplete': instance.profileComplete,
};

_AuthResponseDto _$AuthResponseDtoFromJson(Map<String, dynamic> json) =>
    _AuthResponseDto(
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      profileComplete: json['profileComplete'] as bool? ?? true,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$AuthResponseDtoToJson(_AuthResponseDto instance) =>
    <String, dynamic>{
      'user': instance.user,
      'profileComplete': instance.profileComplete,
      'token': instance.token,
    };
