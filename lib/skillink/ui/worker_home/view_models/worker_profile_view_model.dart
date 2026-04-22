import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/utils/result.dart';

class WorkerProfileState {
  const WorkerProfileState({
    this.isLoading = false,
    this.worker,
    this.reviews = const <Review>[],
    this.isSaving = false,
    this.errorMessage,
    this.saveSuccess = false,
  });

  final bool isLoading;
  final Worker? worker;
  final List<Review> reviews;
  final bool isSaving;
  final String? errorMessage;
  final bool saveSuccess;

  WorkerProfileState copyWith({
    bool? isLoading,
    Worker? worker,
    List<Review>? reviews,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    bool? saveSuccess,
    bool clearSaveSuccess = false,
  }) {
    return WorkerProfileState(
      isLoading: isLoading ?? this.isLoading,
      worker: worker ?? this.worker,
      reviews: reviews ?? this.reviews,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      saveSuccess: clearSaveSuccess
          ? false
          : (saveSuccess ?? this.saveSuccess),
    );
  }
}

class WorkerProfileViewModel extends StateNotifier<WorkerProfileState> {
  WorkerProfileViewModel(this._ref)
      : super(const WorkerProfileState(isLoading: true)) {
    _bootstrap();
  }

  final Ref _ref;

  WorkerRepository get _workers => _ref.read(workerRepositoryProvider);

  Future<void> _bootstrap() async {
    final profileRes = await _workers.getMyProfile();
    if (!mounted) return;

    var worker = profileRes.valueOrNull;
    final reviewsRes = worker != null
        ? await _workers.getReviews(worker.id)
        : const Success<List<Review>>(<Review>[]);
    if (!mounted) return;

    final reviews = reviewsRes.valueOrNull ?? const <Review>[];
    if (worker != null &&
        reviews.isNotEmpty &&
        worker.reviewCount == 0 &&
        worker.rating == 0) {
      final avg =
          reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
      worker = worker.copyWith(
        reviewCount: reviews.length,
        rating: avg,
      );
    }

    state = state.copyWith(
      isLoading: false,
      worker: worker,
      reviews: reviews,
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSaveSuccess: true,
    );
    await _bootstrap();
  }

  Future<void> updateProfile(WorkerProfileInput input) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearSaveSuccess: true,
    );
    final res = await _workers.updateProfile(input);
    if (!mounted) return;
    res.when(
      success: (w) {
        state = state.copyWith(
          isSaving: false,
          worker: w,
          saveSuccess: true,
        );
        _ref.invalidate(currentLabourUserProvider);
      },
      failure: (msg, _) =>
          state = state.copyWith(isSaving: false, errorMessage: msg),
    );
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }
}

final workerProfileViewModelProvider = StateNotifierProvider.autoDispose<
    WorkerProfileViewModel, WorkerProfileState>(
  (ref) => WorkerProfileViewModel(ref),
);
