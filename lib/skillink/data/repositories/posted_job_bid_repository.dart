import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/domain/models/posted_job_bid.dart';
import 'package:skilllink/skillink/utils/result.dart';

abstract class PostedJobBidRepository {
  Stream<List<PostedJobBid>> watchBidsForJob(String jobId);

  Stream<List<PostedJobBid>> watchBidsForWorker(String workerId);

  Future<Result<int>> countNonWithdrawnBidsForJob(String jobId);

  Future<Result<String>> submitWorkerBid({
    required String jobId,
    required String workerId,
    required double visitingCharges,
    required double jobChargesEstimate,
    required int etaMinutes,
    String? note,
  });

  Future<Result<void>> withdrawBid({
    required String jobId,
    required String bidId,
    required String workerId,
  });

  Future<Result<void>> homeownerRejectBid({
    required String jobId,
    required String bidId,
    required String homeownerId,
  });

  Future<Result<PostedJob>> homeownerAcceptBid({
    required String jobId,
    required String bidId,
    required String homeownerId,
  });

  Future<Result<void>> homeownerCounterOffer({
    required String jobId,
    required String homeownerId,
    required double visitingCharges,
    required double jobChargesEstimate,
    String? note,
  });

  Future<Result<void>> homeownerWithdrawCounterOffer({
    required String jobId,
    required String bidId,
    required String homeownerId,
  });

  Future<Result<PostedJob>> workerAcceptCounterOffer({
    required String jobId,
    required String counterBidId,
    required String workerId,
  });

  Future<Result<void>> workerRejectCounterOffer({
    required String jobId,
    required String counterBidId,
    required String workerId,
  });
}
