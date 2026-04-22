import 'package:skilllink/skillink/data/repositories/job_repository.dart';
import 'package:skilllink/skillink/data/services/api_service.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/utils/error_mapper.dart';
import 'package:skilllink/skillink/utils/result.dart';

class RemoteJobRepository implements JobRepository {
  RemoteJobRepository({required ApiService apiService}) : _api = apiService;

  final ApiService _api;


  @override
  Future<Result<Job?>> getActiveJob() async {
    try {
      final res = await _api.get<List<dynamic>>(
        '/users/me/jobs',
        queryParameters: {'status': 'active', 'limit': 1},
      );
      final items = (res.data ?? const <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(Job.fromJson)
          .toList();
      return Success(items.isEmpty ? null : items.first);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<List<Job>>> getRecentJobs({int limit = 10}) async {
    try {
      final res = await _api.get<List<dynamic>>(
        '/users/me/jobs',
        queryParameters: {'limit': limit, 'sort': '-createdAt'},
      );
      final jobs = (res.data ?? const <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(Job.fromJson)
          .toList();
      return Success(jobs);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<List<Job>>> listJobs() async {
    try {
      final res = await _api.get<List<dynamic>>('/users/me/jobs');
      final jobs = (res.data ?? const <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(Job.fromJson)
          .toList();
      return Success(jobs);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<Job>> getJob(String jobId) async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/jobs/$jobId');
      return Success(Job.fromJson(res.data!));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }


  @override
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
  }) async {
    return const Failure(
      'Posted-job booking handoff is not available from the API yet.',
    );
  }

  @override
  Future<Result<Job>> createJob(CreateJobInput input) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/jobs',
        data: <String, dynamic>{
          'workerId': input.workerId,
          'serviceType': input.serviceType,
          'description': input.description,
          'scheduledDate': input.scheduledDate.toIso8601String(),
          'address': input.address.toJson(),
          'paymentMethod': input.paymentMethod.name,
          'photoUrls': input.localPhotoPaths,
        },
      );
      return Success(Job.fromJson(res.data!));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<Job>> submitBid({
    required String jobId,
    required double amount,
  }) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/jobs/$jobId/bids',
        data: {'amount': amount},
      );
      return Success(Job.fromJson(res.data!));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<Job>> acceptBid({
    required String jobId,
    String? bidId,
  }) async {
    try {
      final res = await _api.patch<Map<String, dynamic>>(
        '/jobs/$jobId/bids/${bidId ?? 'latest'}/accept',
      );
      return Success(Job.fromJson(res.data!));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<Job>> advanceJobStatus({
    required String jobId,
    required JobStatus status,
  }) async {
    try {
      final res = await _api.patch<Map<String, dynamic>>(
        '/jobs/$jobId/status',
        data: {'status': status.name},
      );
      return Success(Job.fromJson(res.data!));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<CancelOutcome>> cancelJob({
    required String jobId,
    String? reason,
  }) async {
    try {
      final res = await _api.patch<Map<String, dynamic>>(
        '/jobs/$jobId/cancel',
        data: {'reason': reason},
      );
      final data = res.data!;
      return Success(CancelOutcome(
        job: Job.fromJson(data['job'] as Map<String, dynamic>),
        penaltyApplied: data['penaltyApplied'] as bool? ?? false,
      ));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<Job>> markAsPaid({required String jobId}) async {
    try {
      final res = await _api.patch<Map<String, dynamic>>(
        '/jobs/$jobId/pay',
        data: {'method': 'cash'},
      );
      return Success(Job.fromJson(res.data!));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<Review>> submitReview({
    required String jobId,
    required double rating,
    String? comment,
  }) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/jobs/$jobId/reviews',
        data: <String, dynamic>{
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      return Success(Review.fromJson(res.data!));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }


  @override
  Stream<Job> watchJob(String jobId) {
    return const Stream.empty();
  }

  @override
  Stream<({double lat, double lng})> watchWorkerLocation(String jobId) {
    return const Stream.empty();
  }
}
