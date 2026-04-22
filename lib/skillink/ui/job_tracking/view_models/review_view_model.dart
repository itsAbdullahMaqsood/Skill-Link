import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/ui/job_tracking/view_models/rated_jobs_provider.dart';

enum ReviewOutcome { success, failure }

class ReviewState {
  const ReviewState({
    this.rating = 0,
    this.comment = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.isSubmitted = false,
  });

  final int rating;
  final String comment;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSubmitted;

  bool get canSubmit => rating >= 1 && rating <= 5;

  ReviewState copyWith({
    int? rating,
    String? comment,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSubmitted,
    bool clearError = false,
  }) {
    return ReviewState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class ReviewViewModel extends StateNotifier<ReviewState> {
  ReviewViewModel({required Ref ref, required this.jobId})
      : _ref = ref,
        super(const ReviewState());

  final Ref _ref;
  final String jobId;

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
    final repo = _ref.read(jobRepositoryProvider);
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
