import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skilllink/skillink/domain/models/app_user.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String name,
    required String email,
    String? phone,
    String? role,
    Map<String, dynamic>? address,
    String? avatarUrl,
    @Default('') String cnicNumber,
    @Default('') String cnicFrontUrl,
    @Default('') String cnicBackUrl,
    @Default(true) bool profileComplete,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

extension UserDtoMapper on UserDto {
  AppUser toDomain() {
    return AppUser(
      id: id,
      name: name,
      email: email,
      phone: phone ?? '',
      role: role == 'worker' ? UserRole.worker : UserRole.homeowner,
      address: address != null
          ? StructuredAddress.fromJson(address!)
          : const StructuredAddress(
              street: '', area: '', city: '', postalCode: ''),
      avatarUrl: avatarUrl,
      cnicNumber: cnicNumber,
      cnicFrontUrl: cnicFrontUrl,
      cnicBackUrl: cnicBackUrl,
      profileComplete: profileComplete,
    );
  }
}

@freezed
abstract class AuthResponseDto with _$AuthResponseDto {
  const factory AuthResponseDto({
    required UserDto user,
    @Default(true) bool profileComplete,
    String? token,
  }) = _AuthResponseDto;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);
}
