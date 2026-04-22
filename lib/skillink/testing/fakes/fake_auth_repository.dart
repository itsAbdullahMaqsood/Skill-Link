import 'dart:io';

import 'package:skilllink/skillink/data/repositories/auth_repository.dart';
import 'package:skilllink/skillink/domain/models/app_user.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/utils/result.dart';

class FakeAuthRepository implements AuthRepository {
  AppUser? _currentUser;

  static const _networkLatency = Duration(milliseconds: 600);

  static const _demoHomeowner = AppUser(
    id: 'homeowner_001',
    name: 'Ahmad Khan',
    email: 'ahmad@example.com',
    phone: '+923001234567',
    role: UserRole.homeowner,
    address: StructuredAddress(
      street: '45-B Main Boulevard',
      area: 'Gulberg III',
      city: 'Lahore',
      postalCode: '54660',
    ),
  );

  static const _demoWorker = AppUser(
    id: 'worker_001',
    name: 'Ali Raza',
    email: 'ali.raza@example.com',
    phone: '+923009876543',
    role: UserRole.worker,
    address: StructuredAddress(
      street: '12 Industrial Area',
      area: 'Johar Town',
      city: 'Lahore',
      postalCode: '54782',
    ),
  );

  @override
  Future<Result<AppUser>> signIn(String email, String password) async {
    await Future<void>.delayed(_networkLatency);

    if (email == 'fail@example.com') {
      return const Failure('Incorrect email or password.');
    }
    _currentUser = email == 'worker@example.com'
        ? _demoWorker
        : _demoHomeowner.copyWith(email: email);
    return Success(_currentUser!);
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
    await Future<void>.delayed(_networkLatency);

    _currentUser = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: role,
      address: address,
      cnicNumber: cnicNumber,
      cnicFrontUrl: Uri.file(cnicFront.path).toString(),
      cnicBackUrl: Uri.file(cnicBack.path).toString(),
    );
    return Success(_currentUser!);
  }

  @override
  Future<Result<GoogleSignInOutcome>> signInWithGoogle() async {
    await Future<void>.delayed(_networkLatency);

    _currentUser = AppUser(
      id: 'google_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Google User',
      email: 'googleuser@gmail.com',
      phone: '',
      role: UserRole.homeowner,
      address: const StructuredAddress(
        street: '',
        area: '',
        city: '',
        postalCode: '',
      ),
      avatarUrl: 'https://ui-avatars.com/api/?name=Google+User',
      profileComplete: false,
    );
    return Success((user: _currentUser!, profileComplete: false));
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
    await Future<void>.delayed(_networkLatency);

    final existing = _currentUser;
    if (existing == null) {
      return const Failure('No signed-in user to update.');
    }
    _currentUser = existing.copyWith(
      phone: phone,
      address: address,
      role: role,
      cnicNumber: cnicNumber,
      cnicFrontUrl: Uri.file(cnicFront.path).toString(),
      cnicBackUrl: Uri.file(cnicBack.path).toString(),
      profileComplete: true,
    );
    return Success(_currentUser!);
  }

  @override
  Future<Result<AppUser?>> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return Success(_currentUser);
  }

  @override
  Future<Result<AppUser>> updateUserProfile(UserProfileUpdate update) async {
    await Future<void>.delayed(_networkLatency);
    final existing = _currentUser;
    if (existing == null) {
      return const Failure('Not signed in.');
    }
    _currentUser = existing.copyWith(
      name: update.name ?? existing.name,
      phone: update.phone ?? existing.phone,
      address: update.address ?? existing.address,
      avatarUrl: update.avatarUrl ?? existing.avatarUrl,
    );
    return Success(_currentUser!);
  }

  @override
  Future<Result<void>> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    return const Success(null);
  }
}
