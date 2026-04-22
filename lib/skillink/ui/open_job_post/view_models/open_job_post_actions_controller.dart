import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/open_job_post_repository.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/data/services/recent_worker_open_bid_storage.dart';
import 'package:skilllink/skillink/domain/models/open_job_post_bid.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/utils/result.dart';

enum OpenJobPostActionKind {
  none,
  submitBid,
  selectBid,
  cancel,
}

class OpenJobPostActionsState {
  const OpenJobPostActionsState({
    this.runningAction = OpenJobPostActionKind.none,
    this.errorMessage,
  });

  final OpenJobPostActionKind runningAction;
  final String? errorMessage;

  bool get isBusy => runningAction != OpenJobPostActionKind.none;

  OpenJobPostActionsState copyWith({
    OpenJobPostActionKind? runningAction,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OpenJobPostActionsState(
      runningAction: runningAction ?? this.runningAction,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SubmitBidOutcome {
  const SubmitBidOutcome.success(this.bid) : errorMessage = null;
  const SubmitBidOutcome.failure(this.errorMessage) : bid = null;

  final OpenJobPostBid? bid;
  final String? errorMessage;

  bool get isSuccess => bid != null;
}

class SelectBidOutcome {
  const SelectBidOutcome.success(this.serviceRequestId) : errorMessage = null;
  const SelectBidOutcome.failure(this.errorMessage) : serviceRequestId = null;

  final String? serviceRequestId;
  final String? errorMessage;

  bool get isSuccess => serviceRequestId != null;
}

class OpenJobPostActionsController
    extends StateNotifier<OpenJobPostActionsState> {
  OpenJobPostActionsController({required this.ref, required this.postId})
      : super(const OpenJobPostActionsState());

  final Ref ref;
  final String postId;

  OpenJobPostRepository get _repo => ref.read(openJobPostRepositoryProvider);

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  Future<SubmitBidOutcome> submitBid({
    required num amount,
    required String currency,
    String? note,

    /// When non-null, persists a recent-bid row for the worker home screen.
    String? recentBidDescriptionPreview,
  }) async {
    if (state.isBusy) {
      return const SubmitBidOutcome.failure('Another action is in progress.');
    }
    state = state.copyWith(
      runningAction: OpenJobPostActionKind.submitBid,
      clearError: true,
    );
    final result = await _repo.submitOpenJobPostBid(
      id: postId,
      amount: amount,
      currency: currency,
      note: note,
    );
    if (!mounted) {
      return const SubmitBidOutcome.failure('Cancelled.');
    }
    switch (result) {
      case Success(:final value):
        final bid = value;
        state = state.copyWith(runningAction: OpenJobPostActionKind.none);
        if (recentBidDescriptionPreview != null) {
          final uid = ref.read(authViewModelProvider).user?.id;
          if (uid != null && uid.isNotEmpty) {
            await RecentWorkerOpenBidStorage.record(
              workerUserId: uid,
              postId: postId,
              description: recentBidDescriptionPreview,
              amount: bid.amount,
              currency: bid.currency,
              status: bid.status,
            );
            ref.invalidate(recentLocalWorkerOpenBidsProvider);
          }
        }
        _invalidatePost();
        return SubmitBidOutcome.success(bid);
      case Failure(:final message):
        state = state.copyWith(
          runningAction: OpenJobPostActionKind.none,
          errorMessage: message,
        );
        return SubmitBidOutcome.failure(message);
    }
  }

  Future<SelectBidOutcome> selectBid({required String bidId}) async {
    if (state.isBusy) {
      return const SelectBidOutcome.failure('Another action is in progress.');
    }
    state = state.copyWith(
      runningAction: OpenJobPostActionKind.selectBid,
      clearError: true,
    );
    final result = await _repo.selectOpenJobPostBid(
      postId: postId,
      bidId: bidId,
    );
    if (!mounted) {
      return const SelectBidOutcome.failure('Cancelled.');
    }
    return result.when(
      success: (outcome) {
        state = state.copyWith(runningAction: OpenJobPostActionKind.none);
        _invalidatePost();
        ref.invalidate(
          myServiceRequestsProvider(ServiceRequestRole.customer),
        );
        return SelectBidOutcome.success(outcome.serviceRequestId);
      },
      failure: (message, _) {
        state = state.copyWith(
          runningAction: OpenJobPostActionKind.none,
          errorMessage: message,
        );
        return SelectBidOutcome.failure(message);
      },
    );
  }

  Future<bool> cancelPost() async {
    if (state.isBusy) return false;
    state = state.copyWith(
      runningAction: OpenJobPostActionKind.cancel,
      clearError: true,
    );
    final result = await _repo.cancelOpenJobPost(postId);
    if (!mounted) return false;
    return result.when(
      success: (_) {
        state = state.copyWith(runningAction: OpenJobPostActionKind.none);
        _invalidatePost();
        return true;
      },
      failure: (message, _) {
        state = state.copyWith(
          runningAction: OpenJobPostActionKind.none,
          errorMessage: message,
        );
        return false;
      },
    );
  }

  void _invalidatePost() {
    ref
      ..invalidate(openJobPostByIdProvider(postId))
      ..invalidate(openJobPostBidsProvider(postId))
      ..invalidate(myOpenJobPostsProvider(ServiceRequestRole.customer))
      ..invalidate(myOpenJobPostsProvider(ServiceRequestRole.worker))
      ..invalidate(discoverOpenJobPostsProvider);
  }
}

final openJobPostActionsControllerProvider = StateNotifierProvider.autoDispose
    .family<OpenJobPostActionsController, OpenJobPostActionsState, String>(
        (ref, postId) {
  return OpenJobPostActionsController(ref: ref, postId: postId);
});
