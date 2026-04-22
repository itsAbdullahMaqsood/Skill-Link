import 'package:skilllink/skillink/domain/models/completion_report.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/utils/result.dart';

class PendingCompletionReport {
  const PendingCompletionReport({
    required this.job,
    required this.report,
    required this.viewerRole,
  });

  String get jobId => job.jobId;

  final Job job;
  final CompletionReport report;
  final UserRole viewerRole;
}

abstract class CompletionReportRepository {
  Stream<CompletionReport?> watch(String jobId);

  Stream<List<PendingCompletionReport>> watchPendingForUser({
    required String userId,
    required UserRole role,
  });

  Future<Result<CompletionReport?>> getReport(String jobId);

  Future<Result<CompletionReport>> openReport({
    required String jobId,
    required DateTime createdAt,
  });

  Future<Result<CompletionReport>> submitHomeownerAmount({
    required String jobId,
    required double amount,
  });

  Future<Result<CompletionReport>> submitWorkerAmount({
    required String jobId,
    required double amount,
  });
}
