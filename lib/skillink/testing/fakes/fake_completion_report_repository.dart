import 'dart:async';

import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/repositories/completion_report_repository.dart';
import 'package:skilllink/skillink/data/repositories/job_repository.dart';
import 'package:skilllink/skillink/domain/models/completion_report.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/testing/fakes/fake_job_repository.dart';
import 'package:skilllink/skillink/utils/result.dart';

class FakeCompletionReportRepository implements CompletionReportRepository {
  FakeCompletionReportRepository({required JobRepository jobRepository})
      : _jobs = jobRepository {
    final js = _jobs;
    if (js is FakeJobRepository) {
      _jobsChangedSub = js.jobsChanged.listen((_) => _emitAllPending());
    }
  }

  final JobRepository _jobs;
  StreamSubscription<void>? _jobsChangedSub;

  final Map<String, CompletionReport> _reports = {};

  final Map<String, StreamController<CompletionReport?>> _watchControllers = {};

  final Map<String, StreamController<List<PendingCompletionReport>>>
      _pendingControllers = {};

  StreamController<CompletionReport?> _watchController(String jobId) =>
      _watchControllers.putIfAbsent(
        jobId,
        () => StreamController<CompletionReport?>.broadcast(),
      );

  StreamController<List<PendingCompletionReport>> _pendingController(
    String userId,
    UserRole role,
  ) {
    final key = '${role.name}::$userId';
    return _pendingControllers.putIfAbsent(
      key,
      () => StreamController<List<PendingCompletionReport>>.broadcast(),
    );
  }


  @override
  Stream<CompletionReport?> watch(String jobId) {
    final controller = _watchController(jobId);
    scheduleMicrotask(() {
      if (!controller.isClosed) controller.add(_reports[jobId]);
    });
    return controller.stream;
  }

  @override
  Stream<List<PendingCompletionReport>> watchPendingForUser({
    required String userId,
    required UserRole role,
  }) {
    final controller = _pendingController(userId, role);
    scheduleMicrotask(() async {
      if (controller.isClosed) return;
      final pending = await _computePending(userId: userId, role: role);
      if (controller.isClosed) return;
      controller.add(pending);
    });
    return controller.stream;
  }

  Future<List<PendingCompletionReport>> _computePending({
    required String userId,
    required UserRole role,
  }) async {
    final jobsResult = await _jobs.listJobs();
    final jobs = jobsResult.valueOrNull ?? const <Job>[];
    final completed = jobs.where((j) => j.status == JobStatus.completed);

    final pending = <PendingCompletionReport>[];
    for (final job in completed) {
      final mine = role == UserRole.homeowner
          ? job.userId == userId
          : job.workerId == userId;
      if (!mine) continue;

      final report = _reports[job.jobId];
      if (report == null) continue;
      final iSubmitted = role == UserRole.homeowner
          ? report.homeownerSubmitted
          : report.workerSubmitted;
      if (iSubmitted) continue;
      pending.add(
        PendingCompletionReport(job: job, report: report, viewerRole: role),
      );
    }
    pending.sort((a, b) => a.report.createdAt.compareTo(b.report.createdAt));
    return pending;
  }


  @override
  Future<Result<CompletionReport?>> getReport(String jobId) async {
    return Success(_reports[jobId]);
  }


  @override
  Future<Result<CompletionReport>> openReport({
    required String jobId,
    required DateTime createdAt,
  }) async {
    final existing = _reports[jobId];
    if (existing != null) return Success(existing);
    final report = CompletionReport(jobId: jobId, createdAt: createdAt);
    _reports[jobId] = report;
    _emitWatch(jobId);
    await _emitAllPending();
    return Success(report);
  }

  @override
  Future<Result<CompletionReport>> submitHomeownerAmount({
    required String jobId,
    required double amount,
  }) =>
      _submit(jobId: jobId, amount: amount, isHomeowner: true);

  @override
  Future<Result<CompletionReport>> submitWorkerAmount({
    required String jobId,
    required double amount,
  }) =>
      _submit(jobId: jobId, amount: amount, isHomeowner: false);

  Future<Result<CompletionReport>> _submit({
    required String jobId,
    required double amount,
    required bool isHomeowner,
  }) async {
    if (amount < 0 || !amount.isFinite) {
      return const Failure('Enter a valid amount.');
    }
    final now = DateTime.now();
    var report = _reports[jobId] ??
        CompletionReport(jobId: jobId, createdAt: now);

    report = isHomeowner
        ? report.copyWith(
            homeownerAmount: amount,
            homeownerSubmittedAt: now,
          )
        : report.copyWith(
            workerAmount: amount,
            workerSubmittedAt: now,
          );

    if (report.bothSubmitted && !report.flagged) {
      final h = report.homeownerAmount!;
      final w = report.workerAmount!;
      final largest = h > w ? h : w;
      if (largest > 0 &&
          (h - w).abs() / largest >
              AppConstants.completionAmountDiscrepancyThreshold) {
        report = report.copyWith(
          flagged: true,
          flaggedReason: AppConstants.completionFlagAmountDiscrepancy,
        );
      }
    }

    _reports[jobId] = report;
    _emitWatch(jobId);
    await _emitAllPending();
    return Success(report);
  }


  void _emitWatch(String jobId) {
    final controller = _watchControllers[jobId];
    if (controller != null && !controller.isClosed) {
      controller.add(_reports[jobId]);
    }
  }

  Future<void> _emitAllPending() async {
    if (_pendingControllers.isEmpty) return;
    final entries = _pendingControllers.entries.toList(growable: false);
    for (final entry in entries) {
      if (entry.value.isClosed) continue;
      final parts = entry.key.split('::');
      if (parts.length != 2) continue;
      final role = UserRole.values.firstWhere(
        (r) => r.name == parts[0],
        orElse: () => UserRole.homeowner,
      );
      final userId = parts[1];
      final pending = await _computePending(userId: userId, role: role);
      if (entry.value.isClosed) continue;
      entry.value.add(pending);
    }
  }

  void dispose() {
    _jobsChangedSub?.cancel();
    _jobsChangedSub = null;
    for (final c in _watchControllers.values) {
      if (!c.isClosed) c.close();
    }
    for (final c in _pendingControllers.values) {
      if (!c.isClosed) c.close();
    }
    _watchControllers.clear();
    _pendingControllers.clear();
  }
}
