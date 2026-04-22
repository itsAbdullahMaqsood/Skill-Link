// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bid _$BidFromJson(Map<String, dynamic> json) => _Bid(
  bidId: json['bidId'] as String?,
  bidderId: json['bidderId'] as String,
  amount: (json['amount'] as num).toDouble(),
  submittedAt: DateTime.parse(json['submittedAt'] as String),
  accepted: json['accepted'] as bool? ?? false,
);

Map<String, dynamic> _$BidToJson(_Bid instance) => <String, dynamic>{
  'bidId': instance.bidId,
  'bidderId': instance.bidderId,
  'amount': instance.amount,
  'submittedAt': instance.submittedAt.toIso8601String(),
  'accepted': instance.accepted,
};
