import 'package:skilllink/skillink/domain/models/review.dart';

String _str(dynamic v) {
  if (v == null) return '';
  final s = v.toString().trim();
  return s;
}

Review? reviewFromLabourApiJson(Map<String, dynamic> json) {
  try {
    final id = _str(json['id'] ?? json['_id']);
    if (id.isEmpty) return null;

    var jobId = _str(json['jobId'] ?? json['job_id']);
    if (jobId.isEmpty) {
      final job = json['job'];
      if (job is Map) {
        jobId = _str(job['id'] ?? job['_id']);
      }
    }
    if (jobId.isEmpty) jobId = '-';

    final ratingRaw = json['rating'] ?? json['stars'] ?? json['score'];
    final rating = ratingRaw is num
        ? ratingRaw.toDouble()
        : double.tryParse(_str(ratingRaw)) ?? 0.0;

    final comment = _nullableStr(
      json['comment'] ?? json['text'] ?? json['message'] ?? json['feedback'],
    );

    DateTime createdAt = DateTime.now();
    final createdRaw =
        json['createdAt'] ?? json['created_at'] ?? json['date'] ?? json['time'];
    if (createdRaw is String && createdRaw.isNotEmpty) {
      createdAt = DateTime.tryParse(createdRaw) ?? createdAt;
    } else if (createdRaw is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdRaw);
    }

    String? reviewerName = _nullableStr(json['reviewerName'] ??
        json['reviewer_name'] ??
        json['clientName'] ??
        json['authorName']);
    if (reviewerName == null || reviewerName.isEmpty) {
      final rev = json['reviewer'] ?? json['user'] ?? json['client'];
      if (rev is Map) {
        reviewerName = _nullableStr(
          rev['fullName'] ?? rev['name'] ?? rev['email'],
        );
      }
    }

    return Review(
      id: id,
      jobId: jobId,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      reviewerName: reviewerName,
    );
  } catch (_) {
    return null;
  }
}

String? _nullableStr(dynamic v) {
  final s = _str(v);
  return s.isEmpty ? null : s;
}

List<Review> reviewsFromLabourApiResponse(dynamic data) {
  final raw = <dynamic>[];
  if (data is List) {
    raw.addAll(data);
  } else if (data is Map<String, dynamic>) {
    final list = data['reviews'] ??
        data['data'] ??
        data['items'] ??
        data['results'];
    if (list is List) raw.addAll(list);
  }

  final out = <Review>[];
  for (final e in raw) {
    if (e is! Map) continue;
    final m = Map<String, dynamic>.from(e);
    try {
      out.add(Review.fromJson(m));
    } catch (_) {
      final r = reviewFromLabourApiJson(m);
      if (r != null) out.add(r);
    }
  }
  return out;
}
