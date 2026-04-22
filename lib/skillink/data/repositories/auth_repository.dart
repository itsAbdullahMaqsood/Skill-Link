import 'dart:io';

import 'package:skilllink/skillink/domain/models/app_user.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/utils/result.dart';

typedef GoogleSignInOutcome = ({AppUser user, bool profileComplete});

abstract class AuthRepository {
  Future<Result<AppUser>> signIn(String email, String password);

  Future<Result<AppUser>> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    required StructuredAddress address,
    required String cnicNumber,
    required File cnicFront,
    required File cnicBack,
    List<String>? skillTypes,
  });

  Future<Result<GoogleSignInOutcome>> signInWithGoogle();

  Future<Result<AppUser>> completeProfile({
    required String phone,
    required StructuredAddress address,
    required UserRole role,
    required String cnicNumber,
    required File cnicFront,
    required File cnicBack,
    List<String>? skillTypes,
  });

  Future<Result<AppUser?>> getCurrentUser();

  Future<Result<AppUser>> updateUserProfile(UserProfileUpdate update);

  Future<Result<void>> signOut();
}

class UserProfileUpdate {
  const UserProfileUpdate({
    this.name,
    this.phone,
    this.address,
    this.avatarUrl,
  });

  final String? name;
  final String? phone;
  final StructuredAddress? address;
  final String? avatarUrl;
}
