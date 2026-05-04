import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';

class WorkerProfileState {
  const WorkerProfileState({
    this.isLoading = true,
    this.worker,
    this.reviews = const <Review>[],
    this.errorMessage,
  });

  final bool isLoading;
  final Worker? worker;
  final List<Review> reviews;
  final String? errorMessage;

  WorkerProfileState copyWith({
    bool? isLoading,
    Worker? worker,
    List<Review>? reviews,
    String? errorMessage,
  }) {
    return WorkerProfileState(
      isLoading: isLoading ?? this.isLoading,
      worker: worker ?? this.worker,
      reviews: reviews ?? this.reviews,
      errorMessage: errorMessage,
    );
  }
}

class WorkerProfileViewModel extends StateNotifier<WorkerProfileState> {
  WorkerProfileViewModel(this._ref, this._workerId)
      : super(const WorkerProfileState()) {
    _load();
  }

  final Ref _ref;
  final String _workerId;

  Future<void> _load() async {
    final workerRepo = _ref.read(workerRepositoryProvider);
    final reviewRepo = _ref.read(reviewRepositoryProvider);
    final workerFuture = workerRepo.getWorker(_workerId);
    final summaryFuture = reviewRepo.getUserReviews(_workerId);
    final workerResult = await workerFuture;
    final summaryResult = await summaryFuture;
    if (!mounted) return;

    if (workerResult.isFailure && state.worker == null) {
      state = WorkerProfileState(
        isLoading: false,
        errorMessage: workerResult.errorOrNull,
      );
      return;
    }

    var worker = workerResult.valueOrNull ?? state.worker;
    final summary = summaryResult.valueOrNull;
    final reviews = summary?.reviews ?? state.reviews;

    if (worker != null && summary != null) {
      worker = worker.copyWith(
        rating: summary.user.ratings,
        reviewCount: summary.user.reviewCount,
      );
    }

    state = state.copyWith(
      isLoading: false,
      worker: worker,
      reviews: reviews,
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    _ref.invalidate(labourServiceIdToNameProvider);
    await _load();
  }
}

final workerProfileViewModelProvider = StateNotifierProvider.autoDispose
    .family<WorkerProfileViewModel, WorkerProfileState, String>(
  (ref, workerId) => WorkerProfileViewModel(ref, workerId),
);
