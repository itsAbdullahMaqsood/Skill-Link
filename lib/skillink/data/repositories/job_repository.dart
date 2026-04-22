import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/utils/result.dart';

class CancelOutcome {
  const CancelOutcome({required this.job, required this.penaltyApplied});
  final Job job;
  final bool penaltyApplied;
}

class CreateJobInput {
  const CreateJobInput({
    required this.workerId,
    required this.serviceType,
    required this.description,
    required this.scheduledDate,
    required this.address,
    required this.paymentMethod,
    this.localPhotoPaths = const <String>[],
  });

  final String workerId;
  final String serviceType;
  final String description;
  final DateTime scheduledDate;
  final StructuredAddress address;
  final PaymentMethodInput paymentMethod;
  final List<String> localPhotoPaths;
}

enum PaymentMethodInput { cash, inApp }

abstract class JobRepository {
  Future<Result<Job?>> getActiveJob();

  Future<Result<List<Job>>> getRecentJobs({int limit = 10});

  Future<Result<Job>> createJob(CreateJobInput input);

  Future<Result<Job>> createJobFromPostedAcceptance({
    required String postedJobId,
    required String homeownerId,
    required String workerId,
    required String serviceType,
    required String description,
    required StructuredAddress address,
    required double visitingCharges,
    required double jobChargesEstimate,
    required DateTime scheduledDate,
  });

  Future<Result<Job>> getJob(String jobId);

  Future<Result<List<Job>>> listJobs();

  Stream<Job> watchJob(String jobId);

  Stream<({double lat, double lng})> watchWorkerLocation(String jobId);

  Future<Result<Job>> submitBid({required String jobId, required double amount});

  Future<Result<Job>> acceptBid({required String jobId, String? bidId});

  Future<Result<Job>> advanceJobStatus({
    required String jobId,
    required JobStatus status,
  });

  Future<Result<CancelOutcome>> cancelJob({
    required String jobId,
    String? reason,
  });

  Future<Result<Job>> markAsPaid({required String jobId});

  Future<Result<Review>> submitReview({
    required String jobId,
    required double rating,
    String? comment,
  });
}
