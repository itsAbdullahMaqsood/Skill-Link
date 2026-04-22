import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/auth_repository.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

class ProfileUiState {
  const ProfileUiState({
    this.isSaving = false,
    this.uploadingAvatar = false,
    this.errorMessage,
    this.saveSuccess = false,
    this.avatarSuccessCount = 0,
  });

  final bool isSaving;
  final bool uploadingAvatar;
  final String? errorMessage;
  final bool saveSuccess;
  final int avatarSuccessCount;

  ProfileUiState copyWith({
    bool? isSaving,
    bool? uploadingAvatar,
    String? errorMessage,
    bool clearError = false,
    bool? saveSuccess,
    bool clearSaveSuccess = false,
    int? avatarSuccessCount,
  }) {
    return ProfileUiState(
      isSaving: isSaving ?? this.isSaving,
      uploadingAvatar: uploadingAvatar ?? this.uploadingAvatar,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      saveSuccess: clearSaveSuccess
          ? false
          : (saveSuccess ?? this.saveSuccess),
      avatarSuccessCount: avatarSuccessCount ?? this.avatarSuccessCount,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileUiState> {
  ProfileViewModel(this._ref) : super(const ProfileUiState());

  final Ref _ref;

  Future<void> save({
    required String name,
    required String phone,
    required StructuredAddress address,
  }) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearSaveSuccess: true,
    );
    final res = await _ref.read(authRepositoryProvider).updateUserProfile(
          UserProfileUpdate(name: name, phone: phone, address: address),
        );
    if (!mounted) return;
    res.when(
      success: (user) {
        _ref.read(authViewModelProvider.notifier).setUser(user);
        state = state.copyWith(isSaving: false, saveSuccess: true);
      },
      failure: (msg, _) =>
          state = state.copyWith(isSaving: false, errorMessage: msg),
    );
  }

  Future<void> pickAndUploadAvatar() async {
    final user = _ref.read(authViewModelProvider).user;
    if (user == null) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    state = state.copyWith(uploadingAvatar: true, clearError: true);

    final avatarUrl = Uri.file(file.path).toString();

    final patch = await _ref
        .read(authRepositoryProvider)
        .updateUserProfile(UserProfileUpdate(avatarUrl: avatarUrl));
    if (!mounted) return;
    patch.when(
      success: (u) {
        _ref.read(authViewModelProvider.notifier).setUser(u);
        state = state.copyWith(
          uploadingAvatar: false,
          avatarSuccessCount: state.avatarSuccessCount + 1,
        );
      },
      failure: (msg, _) => state = state.copyWith(
        uploadingAvatar: false,
        errorMessage: msg,
      ),
    );
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  void clearSaveSuccess() {
    if (!state.saveSuccess) return;
    state = state.copyWith(clearSaveSuccess: true);
  }
}

final profileViewModelProvider =
    StateNotifierProvider.autoDispose<ProfileViewModel, ProfileUiState>(
  (ref) => ProfileViewModel(ref),
);
