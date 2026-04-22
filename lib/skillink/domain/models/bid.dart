import 'package:freezed_annotation/freezed_annotation.dart';

part 'bid.freezed.dart';
part 'bid.g.dart';

@freezed
abstract class Bid with _$Bid {
  const factory Bid({
    String? bidId,
    required String bidderId,
    required double amount,
    required DateTime submittedAt,
    @Default(false) bool accepted,
  }) = _Bid;

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);
}

extension BidX on Bid {
  bool get isFromWorker => !isFromHomeowner;
  bool get isFromHomeowner =>
      bidderId.startsWith('homeowner') || bidderId == 'homeowner';
}
