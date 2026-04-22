import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/completion_report_repository.dart';
import 'package:skilllink/skillink/domain/models/completion_report.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/completion_report/view_models/pending_completion_reports_view_model.dart';

class CompletionPromptState {
  const CompletionPromptState({
    this.job,
    this.report,
    this.viewerRole,
    this.bootstrapping = true,
    this.errorMessage,
    this.isSubmitting = false,
    this.submittedReport,
  });

  final Job? job;
  final CompletionReport? report;
  final UserRole? viewerRole;
  final bool bootstrapping;
  final String? errorMessage;
  final bool isSubmitting;

  final CompletionReport? submittedReport;

  bool get isHomeowner => viewerRole == UserRole.homeowner;

  CompletionPromptState copyWith({
    Job? job,
    CompletionReport? report,
    UserRole? viewerRole,
    bool? bootstrapping,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitting,
    CompletionReport? submittedReport,
    bool clearSubmittedReport = false,
  }) {
    return CompletionPromptState(
      job: job ?? this.job,
      report: report ?? this.report,
      viewerRole: viewerRole ?? this.viewerRole,
      bootstrapping: bootstrapping ?? this.bootstrapping,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submittedReport: clearSubmittedReport
          ? null
          : (submittedReport ?? this.submittedReport),
    );
  }
}

class CompletionPromptViewModel extends StateNotifier<CompletionPromptState> {
  CompletionPromptViewModel(this._ref, this._jobId)
      : super(const CompletionPromptState()) {
    _bootstrap();
  }

  final Ref _ref;
  final String _jobId;
  StreamSubscription<CompletionReport?>? _watchSub;

  CompletionReportRepository get _repo =>
      _ref.read(completionReportRepositoryProvider);

  Future<void> _bootstrap() async {
    final auth = _ref.read(authViewModelProvider);
    if (!auth.isAuthenticated) {
      state = state.copyWith(
        bootstrapping: false,
        errorMessage: 'Sign in to report a completed job.',
      );
      return;
    }

    final jobs = _ref.read(jobRepositoryProvider);
    final jobResult = await jobs.getJob(_jobId);
    if (!mounted) return;
    final job = jobResult.valueOrNull;
    if (job == null) {
      state = state.copyWith(
        bootstrapping: false,
        errorMessage: 'Could not find this job.',
      );
      return;
    }

    await _repo.openReport(jobId: _jobId, createdAt: DateTime.now());
    if (!mounted) return;

    state = state.copyWith(
      job: job,
      viewerRole: auth.user!.role,
      bootstrapping: false,
    );

    _watchSub = _repo.watch(_jobId).listen((report) {
      if (!mounted || report == null) return;
      state = state.copyWith(report: report);
    });
  }

  Future<void> submit({required double amount}) async {
    if (state.isSubmitting) return;
    if (state.viewerRole == null || state.job == null) return;
    if (amount < 0 || !amount.isFinite) {
      state = state.copyWith(errorMessage: 'Enter a valid amount.');
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSubmittedReport: true,
    );
    final result = state.isHomeowner
        ? await _repo.submitHomeownerAmount(jobId: _jobId, amount: amount)
        : await _repo.submitWorkerAmount(jobId: _jobId, amount: amount);
    if (!mounted) return;

    result.when(
      success: (report) {
        state = state.copyWith(
          isSubmitting: false,
          report: report,
          submittedReport: report,
        );
      },
      failure: (msg, _) {
        state = state.copyWith(isSubmitting: false, errorMessage: msg);
      },
    );
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  void acknowledgeSubmission() {
    _ref
        .read(acknowledgedCompletionReportsProvider.notifier)
        .acknowledge(_jobId);
    if (state.submittedReport == null) return;
    state = state.copyWith(clearSubmittedReport: true);
  }

  @override
  void dispose() {
    unawaited(_watchSub?.cancel());
    super.dispose();
  }
}

final completionPromptViewModelProvider = StateNotifierProvider.autoDispose
    .family<CompletionPromptViewModel, CompletionPromptState, String>(
  (ref, jobId) => CompletionPromptViewModel(ref, jobId),
);
