import 'package:skilllink/skillink/data/mappers/review_from_labour_api.dart';
import 'package:skilllink/skillink/data/repositories/review_repository.dart';
import 'package:skilllink/skillink/data/services/api_service.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/reviews_summary.dart';
import 'package:skilllink/skillink/utils/error_mapper.dart';
import 'package:skilllink/skillink/utils/result.dart';

class RemoteReviewRepository implements ReviewRepository {
  RemoteReviewRepository({required ApiService apiService}) : _api = apiService;

  final ApiService _api;

  @override
  Future<Result<Review>> submitReview({
    required String jobId,
    required double rating,
    String? comment,
  }) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/reviews',
        data: <String, dynamic>{
          'jobId': jobId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      return Success(reviewFromLabourApiJson(res.data!));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<List<Review>>> getMyReviews({
    required MyReviewsType type,
  }) async {
    try {
      final res = await _api.get<dynamic>(
        '/reviews/my',
        queryParameters: {'type': type.name},
      );
      return Success(reviewsFromLabourApiList(res.data));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<ReviewsSummary>> getUserReviews(String userId) async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/reviews/user/$userId');
      return Success(reviewsSummaryFromJson(res.data!));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }
}
