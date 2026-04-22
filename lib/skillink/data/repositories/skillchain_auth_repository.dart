import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilllink/models/user.dart' as sc;
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/skillink/data/repositories/auth_repository.dart';
import 'package:skilllink/skillink/data/services/api_service.dart';
import 'package:skilllink/skillink/domain/models/app_user.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/utils/result.dart';

const kLabourRolePrefKey = 'skillink_labour_role';

class SkillChainAuthRepository implements AuthRepository {
  SkillChainAuthRepository({
    required AuthService authService,
    required ApiService api,
  })  : _auth = authService,
        _api = api;

  final AuthService _auth;
  // ignore: unused_field
  final ApiService _api;

  @override
  Future<Result<AppUser>> signIn(String email, String password) async {
    return const Failure(
      'Sign-in on the labour side runs through the Login screen. '
      'Open the app, pick Labour Skills, and sign in there.',
    );
  }

  @override
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
  }) async {
    return const Failure(
      'Sign-up runs through the SkillChain (digital) side. Open the app, '
      'create your account there, then choose Labour Skills to land here.',
    );
  }

  @override
  Future<Result<GoogleSignInOutcome>> signInWithGoogle() async {
    return const Failure(
      'Google sign-in runs through the SkillChain (digital) side.',
    );
  }

  @override
  Future<Result<AppUser>> completeProfile({
    required String phone,
    required StructuredAddress address,
    required UserRole role,
    required String cnicNumber,
    required File cnicFront,
    required File cnicBack,
    List<String>? skillTypes,
  }) async {
    return const Failure(
      'Profile completion runs through the SkillChain (digital) side.',
    );
  }

  @override
  Future<Result<AppUser?>> getCurrentUser() async {
    if (!await _auth.isLoggedIn()) return const Success(null);
    final user = await _auth.getCurrentUser();
    if (user == null) return const Success(null);
    return Success(await _toAppUser(user));
  }

  @override
  Future<Result<AppUser>> updateUserProfile(UserProfileUpdate update) async {
    return const Failure(
      'Profile updates happen on the SkillChain (digital) side.',
    );
  }

  @override
  Future<Result<void>> signOut() async {
    await _auth.logout();
    return const Success(null);
  }

  Future<AppUser> _toAppUser(sc.UserModel u) async {
    final UserRole role;
    if (u.labourApiRole.trim().isNotEmpty) {
      role = u.isLabourWorkerRole ? UserRole.worker : UserRole.homeowner;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kLabourRolePrefKey);
      role = raw == 'worker' ? UserRole.worker : UserRole.homeowner;
    }
    return AppUser(
      id: u.id,
      name: u.fullName.isEmpty ? u.email : u.fullName,
      email: u.email,
      phone: u.phoneNumber,
      address: StructuredAddress(
        street: '',
        area: '',
        city: u.location,
        postalCode: '',
      ),
      role: role,
      avatarUrl: u.profileImageUrl.isEmpty ? null : u.profileImageUrl,
      profileComplete: true,
    );
  }
}
