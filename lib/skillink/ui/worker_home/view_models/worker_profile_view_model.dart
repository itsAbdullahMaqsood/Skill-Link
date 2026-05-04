import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/review_repository.dart';
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';

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
  ReviewRepository get _reviews => _ref.read(reviewRepositoryProvider);

  Future<void> _bootstrap() async {
    final profileRes = await _workers.getMyProfile();
    if (!mounted) return;

    var worker = profileRes.valueOrNull;
    var reviews = const <Review>[];

    if (worker != null) {
      final summaryRes = await _reviews.getUserReviews(worker.id);
      if (!mounted) return;
      final summary = summaryRes.valueOrNull;
      if (summary != null) {
        reviews = summary.reviews;
        worker = worker.copyWith(
          rating: summary.user.ratings,
          reviewCount: summary.user.reviewCount,
        );
      }
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
    _ref.invalidate(currentLabourUserProvider);
    _ref.invalidate(labourServiceIdToNameProvider);
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

  void clearSaveSuccess() {
    if (!state.saveSuccess) return;
    state = state.copyWith(clearSaveSuccess: true);
  }
}

final workerProfileViewModelProvider = StateNotifierProvider.autoDispose<
    WorkerProfileViewModel, WorkerProfileState>(
  (ref) => WorkerProfileViewModel(ref),
);
