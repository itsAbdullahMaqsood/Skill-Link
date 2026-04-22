import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/utils/result.dart';

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
    final repo = _ref.read(workerRepositoryProvider);
    final results = await Future.wait([
      repo.getWorker(_workerId),
      repo.getReviews(_workerId),
    ]);
    if (!mounted) return;

    final workerResult = results[0] as Result<Worker>;
    final reviewsResult = results[1] as Result<List<Review>>;

    if (workerResult.isFailure && state.worker == null) {
      state = WorkerProfileState(
        isLoading: false,
        errorMessage: workerResult.errorOrNull,
      );
      return;
    }

    var worker = workerResult.valueOrNull ?? state.worker;
    final reviews = reviewsResult.valueOrNull ?? state.reviews;
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
    state = state.copyWith(isLoading: true);
    await _load();
  }
}

final workerProfileViewModelProvider = StateNotifierProvider.autoDispose
    .family<WorkerProfileViewModel, WorkerProfileState, String>(
  (ref, workerId) => WorkerProfileViewModel(ref, workerId),
);
