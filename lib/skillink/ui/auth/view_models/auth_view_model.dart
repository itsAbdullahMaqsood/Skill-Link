import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/app_user.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.profileComplete = true,
    this.bootstrapping = false,
  });

  const AuthState.bootstrapping() : this(bootstrapping: true);

  final AppUser? user;
  final bool isLoading;
  final bool profileComplete;
  final bool bootstrapping;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    bool? profileComplete,
    bool? bootstrapping,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      profileComplete: profileComplete ?? this.profileComplete,
      bootstrapping: bootstrapping ?? this.bootstrapping,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel(this._ref) : super(const AuthState.bootstrapping()) {
    unawaited(_restoreSession());
  }

  final Ref _ref;

  Future<void> _restoreSession() async {
    final repo = _ref.read(authRepositoryProvider);
    final result = await repo.getCurrentUser();
    if (!mounted) return;
    result.when(
      success: (user) {
        state = user == null
            ? const AuthState()
            : AuthState(
                user: user,
                profileComplete: user.profileComplete,
              );
      },
      failure: (_, _) => state = const AuthState(),
    );
  }

  void setUser(AppUser user, {bool profileComplete = true}) {
    state = AuthState(user: user, profileComplete: profileComplete);
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(authRepositoryProvider);
    await repo.signOut();
    if (!mounted) return;
    state = const AuthState();
  }

  Future<void> reloadSession() async {
    final res = await _ref.read(authRepositoryProvider).getCurrentUser();
    if (!mounted) return;
    res.when(
      success: (user) {
        if (user == null) {
          state = const AuthState();
        } else {
          state = AuthState(
            user: user,
            profileComplete: user.profileComplete,
          );
        }
      },
      failure: (message, _) {
      },
    );
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref);
});
