// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'posted_job_bid.freezed.dart';
part 'posted_job_bid.g.dart';

enum PostedBidOfferedBy {
  worker,
  homeowner,
}

PostedBidOfferedBy _postedBidOfferedByFromJson(Object? json) {
  final s = json as String?;
  if (s == 'homeowner') return PostedBidOfferedBy.homeowner;
  return PostedBidOfferedBy.worker;
}

String _postedBidOfferedByToJson(PostedBidOfferedBy v) => v.name;

enum PostedBidStatus {
  pending,
  accepted,
  rejected,
  counterOffered,
  withdrawn,
}

PostedBidStatus _postedBidStatusFromJson(Object? json) {
  final s = json as String?;
  if (s == null || s.isEmpty) return PostedBidStatus.pending;
  if (s == 'counter_offered') return PostedBidStatus.counterOffered;
  return PostedBidStatus.values.firstWhere(
    (e) => e.name == s,
    orElse: () => PostedBidStatus.pending,
  );
}

String _postedBidStatusToJson(PostedBidStatus v) => switch (v) {
      PostedBidStatus.counterOffered => 'counter_offered',
      _ => v.name,
    };

@freezed
abstract class PostedJobBid with _$PostedJobBid {
  const factory PostedJobBid({
    required String bidId,
    required String jobId,
    String? workerId,
    @JsonKey(fromJson: _postedBidOfferedByFromJson, toJson: _postedBidOfferedByToJson)
    @Default(PostedBidOfferedBy.worker)
    PostedBidOfferedBy offeredBy,
    required double visitingCharges,
    required double jobChargesEstimate,
    String? note,
    @Default(0) int etaMinutes,
    required DateTime submittedAt,
    @JsonKey(fromJson: _postedBidStatusFromJson, toJson: _postedBidStatusToJson)
    @Default(PostedBidStatus.pending)
    PostedBidStatus status,
  }) = _PostedJobBid;

  factory PostedJobBid.fromJson(Map<String, dynamic> json) =>
      _$PostedJobBidFromJson(json);
}

extension PostedJobBidX on PostedJobBid {
  double get totalEstimate => visitingCharges + jobChargesEstimate;
}

extension PostedBidStatusX on PostedBidStatus {
  String get displayLabel => switch (this) {
        PostedBidStatus.pending => 'Pending',
        PostedBidStatus.accepted => 'Accepted',
        PostedBidStatus.rejected => 'Rejected',
        PostedBidStatus.counterOffered => 'Counter-offered',
        PostedBidStatus.withdrawn => 'Withdrawn',
      };
}
