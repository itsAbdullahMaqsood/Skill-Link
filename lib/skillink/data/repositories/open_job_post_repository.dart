import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/domain/models/open_job_post_bid.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/utils/result.dart';

class CreateOpenJobPostInput {
  const CreateOpenJobPostInput({
    required this.description,
    required this.scheduledServiceDate,
    required this.timeSlotStart,
    required this.timeSlotEnd,
    required this.serviceAddress,
    required this.paymentMethod,
    this.localPhotoPaths = const <String>[],
  });

  final String description;

  final DateTime scheduledServiceDate;

  final String timeSlotStart;
  final String timeSlotEnd;

  final String serviceAddress;
  final ServiceRequestPaymentMethod paymentMethod;

  final List<String> localPhotoPaths;
}

class SelectOpenJobPostBidResult {
  const SelectOpenJobPostBidResult({
    required this.serviceRequestId,
    required this.post,
  });

  final String serviceRequestId;
  final OpenJobPost post;
}

abstract class OpenJobPostRepository {
  Future<Result<OpenJobPost>> createOpenJobPost(CreateOpenJobPostInput input);

  Future<Result<List<OpenJobPost>>> listMyOpenJobPosts({
    required ServiceRequestRole role,
  });

  Future<Result<List<OpenJobPost>>> discoverOpenJobPosts();

  Future<Result<OpenJobPost>> getOpenJobPost(String id);

  Future<Result<List<OpenJobPostBid>>> listBidsForOpenJobPost(String id);

  Future<Result<OpenJobPostBid>> submitOpenJobPostBid({
    required String id,
    required num amount,
    required String currency,
    String? note,
  });

  Future<Result<SelectOpenJobPostBidResult>> selectOpenJobPostBid({
    required String postId,
    required String bidId,
  });

  Future<Result<OpenJobPost>> cancelOpenJobPost(String id);
}
