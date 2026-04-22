import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/job_repository.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';

class WorkerJobDetailState {
  const WorkerJobDetailState({
    this.isLoading = true,
    this.job,
    this.isBusy = false,
    this.errorMessage,
  });

  final bool isLoading;
  final Job? job;
  final bool isBusy;
  final String? errorMessage;

  WorkerJobDetailState copyWith({
    bool? isLoading,
    Job? job,
    bool? isBusy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WorkerJobDetailState(
      isLoading: isLoading ?? this.isLoading,
      job: job ?? this.job,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class WorkerJobDetailViewModel extends StateNotifier<WorkerJobDetailState> {
  WorkerJobDetailViewModel(this._ref, this._jobId)
      : super(const WorkerJobDetailState()) {
    _bootstrap();
  }

  final Ref _ref;
  final String _jobId;
  StreamSubscription<Job>? _jobSub;

  JobRepository get _jobs => _ref.read(jobRepositoryProvider);

  Future<void> _bootstrap() async {
    final res = await _jobs.getJob(_jobId);
    if (!mounted) return;
    res.when(
      success: (job) {
        state = state.copyWith(isLoading: false, job: job);
        _subscribe();
      },
      failure: (msg, _) {
        state = state.copyWith(isLoading: false, errorMessage: msg);
      },
    );
  }

  void _subscribe() {
    _jobSub?.cancel();
    _jobSub = _jobs.watchJob(_jobId).listen((job) {
      if (!mounted) return;
      state = state.copyWith(job: job);
    });
  }

  Future<void> submitBid(double amount) async {
    state = state.copyWith(isBusy: true, clearError: true);
    final res = await _jobs.submitBid(jobId: _jobId, amount: amount);
    if (!mounted) return;
    res.when(
      success: (job) => state = state.copyWith(isBusy: false, job: job),
      failure: (msg, _) =>
          state = state.copyWith(isBusy: false, errorMessage: msg),
    );
  }

  Future<void> acceptBid() async {
    state = state.copyWith(isBusy: true, clearError: true);
    final res = await _jobs.acceptBid(jobId: _jobId);
    if (!mounted) return;
    res.when(
      success: (job) => state = state.copyWith(isBusy: false, job: job),
      failure: (msg, _) =>
          state = state.copyWith(isBusy: false, errorMessage: msg),
    );
  }

  Future<void> advanceStatus() async {
    final job = state.job;
    if (job == null) return;

    final next = _nextStatus(job.status);
    if (next == null) return;

    state = state.copyWith(isBusy: true, clearError: true);

    final res = await _jobs.advanceJobStatus(jobId: _jobId, status: next);
    if (!mounted) return;
    res.when(
      success: (j) {
        state = state.copyWith(isBusy: false, job: j);
        if (j.status == JobStatus.completed) {
          unawaited(
            _ref.read(completionReportRepositoryProvider).openReport(
                  jobId: j.jobId,
                  createdAt: DateTime.now(),
                ),
          );
        }
      },
      failure: (msg, _) =>
          state = state.copyWith(isBusy: false, errorMessage: msg),
    );
  }

  Future<void> retry() async {
    state = const WorkerJobDetailState(isLoading: true);
    await _bootstrap();
  }

  Future<void> cancelJob({String? reason}) async {
    state = state.copyWith(isBusy: true, clearError: true);
    final res = await _jobs.cancelJob(jobId: _jobId, reason: reason);
    if (!mounted) return;
    res.when(
      success: (outcome) =>
          state = state.copyWith(isBusy: false, job: outcome.job),
      failure: (msg, _) =>
          state = state.copyWith(isBusy: false, errorMessage: msg),
    );
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  static JobStatus? _nextStatus(JobStatus current) => switch (current) {
        JobStatus.bidAccepted => JobStatus.onTheWay,
        JobStatus.onTheWay => JobStatus.arrived,
        JobStatus.arrived => JobStatus.inProgress,
        JobStatus.inProgress => JobStatus.completed,
        _ => null,
      };

  @override
  void dispose() {
    _jobSub?.cancel();
    super.dispose();
  }
}

final workerJobDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<WorkerJobDetailViewModel, WorkerJobDetailState, String>(
  (ref, jobId) => WorkerJobDetailViewModel(ref, jobId),
);
