import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String name,
    required String email,
    required String phone,
    required StructuredAddress address,
    required UserRole role,
    String? avatarUrl,
    @Default('') String cnicNumber,
    @Default('') String cnicFrontUrl,
    @Default('') String cnicBackUrl,
    @Default(true) bool profileComplete,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
