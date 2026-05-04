import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/reviews_summary.dart';

String _str(dynamic v) => v == null ? '' : v.toString().trim();

String? _nullableStr(dynamic v) {
  final s = _str(v);
  return s.isEmpty ? null : s;
}

DateTime? _parseDate(dynamic raw) {
  if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
  if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
  return null;
}

Review reviewFromLabourApiJson(Map<String, dynamic> json) {
  final ratingRaw = json['rating'];
  final rating = ratingRaw is num
      ? ratingRaw.toDouble()
      : double.tryParse(_str(ratingRaw)) ?? 0.0;
  return Review(
    id: _str(json['id']),
    jobId: _str(json['jobId']),
    rating: rating,
    comment: _nullableStr(json['comment']),
    createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
    reviewerId: _nullableStr(json['reviewerId']),
    revieweeId: _nullableStr(json['revieweeId']),
    serviceRequestId: _nullableStr(json['serviceRequestId']),
    updatedAt: _parseDate(json['updatedAt']),
  );
}

List<Review> reviewsFromLabourApiList(dynamic data) {
  if (data is! List) return const <Review>[];
  return data
      .whereType<Map>()
      .map((e) => reviewFromLabourApiJson(Map<String, dynamic>.from(e)))
      .toList();
}

ReviewUserSummary reviewUserSummaryFromJson(Map<String, dynamic> json) {
  final ratingsRaw = json['ratings'];
  final ratings = ratingsRaw is num
      ? ratingsRaw.toDouble()
      : double.tryParse(_str(ratingsRaw)) ?? 0.0;
  final countRaw = json['reviewCount'];
  final count = countRaw is num
      ? countRaw.toInt()
      : int.tryParse(_str(countRaw)) ?? 0;
  return ReviewUserSummary(
    id: _str(json['id']),
    fullName: _str(json['fullName']),
    profilePic: _nullableStr(json['profilePic']),
    ratings: ratings,
    reviewCount: count,
  );
}

ReviewsSummary reviewsSummaryFromJson(Map<String, dynamic> json) {
  final userJson = json['user'];
  final user = userJson is Map<String, dynamic>
      ? reviewUserSummaryFromJson(userJson)
      : const ReviewUserSummary(id: '', fullName: '');
  final reviews = reviewsFromLabourApiList(json['reviews']);
  return ReviewsSummary(user: user, reviews: reviews);
}
