import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/job_repository.dart';
import 'package:skilllink/skillink/domain/models/job.dart';

class WorkerJobsState {
  const WorkerJobsState({
    this.isLoading = false,
    this.activeJob,
    this.errorMessage,
  });

  final bool isLoading;
  final Job? activeJob;
  final String? errorMessage;

  WorkerJobsState copyWith({
    bool? isLoading,
    Job? activeJob,
    String? errorMessage,
    bool clearError = false,
    bool clearActiveJob = false,
  }) {
    return WorkerJobsState(
      isLoading: isLoading ?? this.isLoading,
      activeJob: clearActiveJob ? null : (activeJob ?? this.activeJob),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class WorkerJobsViewModel extends StateNotifier<WorkerJobsState> {
  WorkerJobsViewModel(this._ref)
      : super(const WorkerJobsState(isLoading: true)) {
    _bootstrap();
  }

  final Ref _ref;
  StreamSubscription<Job>? _jobSub;

  JobRepository get _jobs => _ref.read(jobRepositoryProvider);

  Future<void> _bootstrap() async {
    final activeRes = await _jobs.getActiveJob();
    if (!mounted) return;

    final active = activeRes.valueOrNull;

    state = state.copyWith(
      isLoading: false,
      activeJob: active,
      clearError: true,
    );

    if (active != null) _subscribeJob(active.jobId);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final activeRes = await _jobs.getActiveJob();
    if (!mounted) return;

    final active = activeRes.valueOrNull;

    state = state.copyWith(
      isLoading: false,
      activeJob: active,
      clearError: true,
    );

    if (active != null) {
      _subscribeJob(active.jobId);
    } else {
      _jobSub?.cancel();
      _jobSub = null;
    }
  }

  void _subscribeJob(String jobId) {
    _jobSub?.cancel();
    _jobSub = _jobs.watchJob(jobId).listen((job) {
      if (!mounted) return;
      state = state.copyWith(activeJob: job);
    });
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _jobSub?.cancel();
    super.dispose();
  }
}

final workerJobsViewModelProvider =
    StateNotifierProvider.autoDispose<WorkerJobsViewModel, WorkerJobsState>(
  (ref) => WorkerJobsViewModel(ref),
);
