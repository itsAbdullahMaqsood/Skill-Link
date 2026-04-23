import 'dart:async';

import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/repositories/completion_report_repository.dart';
import 'package:skilllink/skillink/data/repositories/job_repository.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/completion_report.dart';
import 'package:skilllink/skillink/domain/logic/job_completion_prompt_mapper.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/utils/result.dart';

/// Client-side completion prompts for [Job] and [ServiceRequest] flows until a
/// dedicated backend store exists. Pending completion is recomputed on a
/// short interval so both parties are nudged after a job/request completes.
class UnifiedCompletionReportRepository implements CompletionReportRepository {
  UnifiedCompletionReportRepository({
    required JobRepository jobRepository,
    required ServiceRequestRepository serviceRequestRepository,
  })  : _jobs = jobRepository,
        _requests = serviceRequestRepository;

  final JobRepository _jobs;
  final ServiceRequestRepository _requests;

  final Map<String, CompletionReport> _reports = {};
  final Map<String, StreamController<CompletionReport?>> _watchControllers = {};

  StreamController<CompletionReport?> _watchController(String jobId) =>
      _watchControllers.putIfAbsent(
        jobId,
        () => StreamController<CompletionReport?>.broadcast(),
      );

  void _emitWatch(String jobId) {
    final c = _watchControllers[jobId];
    if (c != null && !c.isClosed) {
      c.add(_reports[jobId]);
    }
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
  }) async* {
    yield await _computePending(userId: userId, role: role);
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 2));
      yield await _computePending(userId: userId, role: role);
    }
  }

  Future<List<PendingCompletionReport>> _computePending({
    required String userId,
    required UserRole role,
  }) async {
    final pending = <PendingCompletionReport>[];

    final jobsResult = await _jobs.listJobs();
    final jobs = jobsResult.valueOrNull ?? const <Job>[];
    for (final job in jobs.where((j) => j.status == JobStatus.completed)) {
      final mine = role == UserRole.homeowner
          ? job.userId == userId
          : (job.workerId == userId);
      if (!mine) continue;

      // Only prompt after [openReport] ran for this completion (same session).
      // Do not auto-open for every historical completed job on app start.
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

    final srResult = await _requests.listMyRequests(
      role: role == UserRole.homeowner
          ? ServiceRequestRole.customer
          : ServiceRequestRole.worker,
    );
    final srs = srResult.valueOrNull ?? const <ServiceRequest>[];
    for (final sr in srs.where((r) => r.status == ServiceRequestStatus.completed)) {
      final mine = role == UserRole.homeowner
          ? (sr.requestingUserId == userId ||
              (sr.requestingCustomer?.id == userId))
          : (sr.requestedWorkerId == userId ||
              (sr.assignedWorker?.id == userId));
      if (!mine) continue;

      final report = _reports[sr.id];
      if (report == null) continue;

      final iSubmitted = role == UserRole.homeowner
          ? report.homeownerSubmitted
          : report.workerSubmitted;
      if (iSubmitted) continue;

      pending.add(
        PendingCompletionReport(
          job: jobForCompletionPrompt(sr),
          report: report,
          viewerRole: role,
        ),
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
    if (existing != null) {
      return Success(existing);
    }
    final report = CompletionReport(jobId: jobId, createdAt: createdAt);
    _reports[jobId] = report;
    _emitWatch(jobId);
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
    return Success(report);
  }

  void dispose() {
    for (final c in _watchControllers.values) {
      if (!c.isClosed) c.close();
    }
    _watchControllers.clear();
  }
}
