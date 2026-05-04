import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/review_repository.dart';
import 'package:skilllink/skillink/ui/job_tracking/view_models/rated_jobs_provider.dart';

enum ReviewOutcome { success, failure }

class ReviewState {
  const ReviewState({
    this.rating = 0,
    this.comment = '',
    this.isLoading = true,
    this.alreadyReviewed = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSubmitted = false,
  });

  final int rating;
  final String comment;
  final bool isLoading;
  final bool alreadyReviewed;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSubmitted;

  bool get canSubmit =>
      !alreadyReviewed && rating >= 1 && rating <= 5;

  ReviewState copyWith({
    int? rating,
    String? comment,
    bool? isLoading,
    bool? alreadyReviewed,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSubmitted,
    bool clearError = false,
  }) {
    return ReviewState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isLoading: isLoading ?? this.isLoading,
      alreadyReviewed: alreadyReviewed ?? this.alreadyReviewed,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class ReviewViewModel extends StateNotifier<ReviewState> {
  ReviewViewModel({required Ref ref, required this.jobId})
      : _ref = ref,
        super(const ReviewState()) {
    _checkAlreadyReviewed();
  }

  final Ref _ref;
  final String jobId;

  Future<void> _checkAlreadyReviewed() async {
    final repo = _ref.read(reviewRepositoryProvider);
    final res = await repo.getMyReviews(type: MyReviewsType.given);
    if (!mounted) return;
    res.when(
      success: (list) {
        final found = list.any((r) => r.jobId == jobId);
        state = state.copyWith(isLoading: false, alreadyReviewed: found);
        if (found) {
          _ref.read(ratedJobsTrackerProvider.notifier).markRated(jobId);
        }
      },
      failure: (_, __) => state = state.copyWith(isLoading: false),
    );
  }

  void setRating(int stars) =>
      state = state.copyWith(rating: stars, clearError: true);

  void setComment(String value) =>
      state = state.copyWith(comment: value);

  Future<ReviewOutcome> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(errorMessage: 'Please pick a star rating.');
      return ReviewOutcome.failure;
    }
    state = state.copyWith(isSubmitting: true, clearError: true);
    final repo = _ref.read(reviewRepositoryProvider);
    final result = await repo.submitReview(
      jobId: jobId,
      rating: state.rating.toDouble(),
      comment: state.comment.trim().isEmpty ? null : state.comment.trim(),
    );
    if (!mounted) return ReviewOutcome.failure;
    return result.when(
      success: (_) {
        state = state.copyWith(isSubmitting: false, isSubmitted: true);
        _ref.read(ratedJobsTrackerProvider.notifier).markRated(jobId);
        _ref.invalidate(reviewedJobIdsProvider);
        return ReviewOutcome.success;
      },
      failure: (msg, _) {
        state = state.copyWith(isSubmitting: false, errorMessage: msg);
        return ReviewOutcome.failure;
      },
    );
  }
}

final reviewViewModelProvider = StateNotifierProvider.autoDispose
    .family<ReviewViewModel, ReviewState, String>((ref, jobId) {
  return ReviewViewModel(ref: ref, jobId: jobId);
});
