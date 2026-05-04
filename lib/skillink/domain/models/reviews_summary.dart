import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skilllink/skillink/domain/models/review.dart';

part 'reviews_summary.freezed.dart';
part 'reviews_summary.g.dart';

@freezed
abstract class ReviewUserSummary with _$ReviewUserSummary {
  const factory ReviewUserSummary({
    required String id,
    required String fullName,
    String? profilePic,
    @Default(0.0) double ratings,
    @Default(0) int reviewCount,
  }) = _ReviewUserSummary;

  factory ReviewUserSummary.fromJson(Map<String, dynamic> json) =>
      _$ReviewUserSummaryFromJson(json);
}

@freezed
abstract class ReviewsSummary with _$ReviewsSummary {
  const factory ReviewsSummary({
    required ReviewUserSummary user,
    @Default(<Review>[]) List<Review> reviews,
  }) = _ReviewsSummary;

  factory ReviewsSummary.fromJson(Map<String, dynamic> json) =>
      _$ReviewsSummaryFromJson(json);
}
