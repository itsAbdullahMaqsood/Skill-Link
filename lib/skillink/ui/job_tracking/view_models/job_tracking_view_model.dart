import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/bid.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';

class JobTrackingState {
  const JobTrackingState({
    this.job,
    this.isLoading = true,
    this.isBusy = false,
    this.errorMessage,
    this.cancellationPenaltyApplied,
  });

  final Job? job;
  final bool isLoading;

  final bool isBusy;
  final String? errorMessage;

  final bool? cancellationPenaltyApplied;

  bool get inCancellationGrace {
    if (job == null) return false;
    final elapsed = DateTime.now().difference(job!.createdAt);
    return elapsed <= AppConstants.cancellationGracePeriod;
  }

  bool get canCancel {
    final s = job?.status;
    if (s == null) return false;
    if (s == JobStatus.inProgress ||
        s == JobStatus.completed ||
        s.isCancelled) {
      return false;
    }
    return true;
  }

  bool get canMarkPaid =>
      job != null &&
      job!.status == JobStatus.completed &&
      !job!.paid;

  bool get showLiveMap =>
      job?.status == JobStatus.onTheWay;

  JobTrackingState copyWith({
    Job? job,
    bool? isLoading,
    bool? isBusy,
    String? errorMessage,
    bool? cancellationPenaltyApplied,
    bool clearError = false,
    bool clearCancellationOutcome = false,
  }) {
    return JobTrackingState(
      job: job ?? this.job,
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      cancellationPenaltyApplied: clearCancellationOutcome
          ? null
          : (cancellationPenaltyApplied ?? this.cancellationPenaltyApplied),
    );
  }
}

class JobTrackingViewModel extends StateNotifier<JobTrackingState> {
  JobTrackingViewModel({required Ref ref, required this.jobId})
      : _ref = ref,
        super(const JobTrackingState()) {
    _bootstrap();
  }

  final Ref _ref;
  final String jobId;

  StreamSubscription<Job>? _watchSub;
  Timer? _pollTimer;

  Future<void> _bootstrap() async {
    final repo = _ref.read(jobRepositoryProvider);
    final result = await repo.getJob(jobId);
    if (!mounted) return;
    result.when(
      success: (job) {
        state = state.copyWith(job: job, isLoading: false);
        _subscribeOrPoll();
      },
      failure: (msg, _) {
        state = state.copyWith(isLoading: false, errorMessage: msg);
      },
    );
  }

  Future<void> retry() async {
    if (state.isLoading || state.job != null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    await _bootstrap();
  }

  void _subscribeOrPoll() {
    if (_watchSub != null || _pollTimer != null) return;

    final repo = _ref.read(jobRepositoryProvider);
    _watchSub = repo.watchJob(jobId).listen(
      (job) => state = state.copyWith(job: job, isLoading: false),
      onError: (Object _) {},
    );

    _pollTimer = Timer.periodic(AppConstants.jobStatusPollInterval, (_) async {
      final result = await repo.getJob(jobId);
      result.when(
        success: (job) {
          if (mounted) state = state.copyWith(job: job);
        },
        failure: (_, _) {},
      );
    });
  }

  Future<void> acceptBid([String? bidId]) async {
    if (state.isBusy) return;
    state = state.copyWith(isBusy: true, clearError: true);
    final repo = _ref.read(jobRepositoryProvider);
    final result = await repo.acceptBid(jobId: jobId, bidId: bidId);
    if (!mounted) return;
    result.when(
      success: (job) => state = state.copyWith(job: job, isBusy: false),
      failure: (msg, _) =>
          state = state.copyWith(isBusy: false, errorMessage: msg),
    );
  }

  Future<void> counterOffer(double amount) async {
    if (state.isBusy) return;
    state = state.copyWith(isBusy: true, clearError: true);
    final repo = _ref.read(jobRepositoryProvider);
    final result = await repo.submitBid(jobId: jobId, amount: amount);
    if (!mounted) return;
    result.when(
      success: (job) => state = state.copyWith(job: job, isBusy: false),
      failure: (msg, _) =>
          state = state.copyWith(isBusy: false, errorMessage: msg),
    );
  }

  Future<void> cancel({String? reason}) async {
    if (state.isBusy) return;
    state = state.copyWith(isBusy: true, clearError: true);
    final repo = _ref.read(jobRepositoryProvider);
    final result = await repo.cancelJob(jobId: jobId, reason: reason);
    if (!mounted) return;
    result.when(
      success: (outcome) {
        state = state.copyWith(
          job: outcome.job,
          isBusy: false,
          cancellationPenaltyApplied: outcome.penaltyApplied,
        );
      },
      failure: (msg, _) =>
          state = state.copyWith(isBusy: false, errorMessage: msg),
    );
  }

  Future<void> markAsPaid() async {
    if (state.isBusy) return;
    state = state.copyWith(isBusy: true, clearError: true);
    final repo = _ref.read(jobRepositoryProvider);
    final result = await repo.markAsPaid(jobId: jobId);
    if (!mounted) return;
    result.when(
      success: (job) => state = state.copyWith(job: job, isBusy: false),
      failure: (msg, _) =>
          state = state.copyWith(isBusy: false, errorMessage: msg),
    );
  }

  Bid? get pendingWorkerBid {
    final job = state.job;
    if (job == null) return null;
    for (final b in job.bidHistory.reversed) {
      if (b.isFromHomeowner) continue;
      if (b.accepted) return null;
      return b;
    }
    return null;
  }

  Stream<({double lat, double lng})> watchLocation() =>
      _ref.read(jobRepositoryProvider).watchWorkerLocation(jobId);

  void clearError() => state = state.copyWith(clearError: true);

  void clearCancellationOutcome() =>
      state = state.copyWith(clearCancellationOutcome: true);

  @override
  void dispose() {
    _watchSub?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }
}

final jobTrackingViewModelProvider = StateNotifierProvider.autoDispose
    .family<JobTrackingViewModel, JobTrackingState, String>((ref, jobId) {
  return JobTrackingViewModel(ref: ref, jobId: jobId);
});
