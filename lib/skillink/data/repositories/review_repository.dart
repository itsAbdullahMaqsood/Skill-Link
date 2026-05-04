import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/reviews_summary.dart';
import 'package:skilllink/skillink/utils/result.dart';

enum MyReviewsType { received, given }

abstract class ReviewRepository {
  Future<Result<Review>> submitReview({
    required String jobId,
    required double rating,
    String? comment,
  });

  Future<Result<List<Review>>> getMyReviews({required MyReviewsType type});

  Future<Result<ReviewsSummary>> getUserReviews(String userId);
}
