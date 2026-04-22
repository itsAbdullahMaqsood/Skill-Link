// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posted_job_bid.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostedJobBid _$PostedJobBidFromJson(Map<String, dynamic> json) =>
    _PostedJobBid(
      bidId: json['bidId'] as String,
      jobId: json['jobId'] as String,
      workerId: json['workerId'] as String?,
      offeredBy: json['offeredBy'] == null
          ? PostedBidOfferedBy.worker
          : _postedBidOfferedByFromJson(json['offeredBy']),
      visitingCharges: (json['visitingCharges'] as num).toDouble(),
      jobChargesEstimate: (json['jobChargesEstimate'] as num).toDouble(),
      note: json['note'] as String?,
      etaMinutes: (json['etaMinutes'] as num?)?.toInt() ?? 0,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      status: json['status'] == null
          ? PostedBidStatus.pending
          : _postedBidStatusFromJson(json['status']),
    );

Map<String, dynamic> _$PostedJobBidToJson(_PostedJobBid instance) =>
    <String, dynamic>{
      'bidId': instance.bidId,
      'jobId': instance.jobId,
      'workerId': instance.workerId,
      'offeredBy': _postedBidOfferedByToJson(instance.offeredBy),
      'visitingCharges': instance.visitingCharges,
      'jobChargesEstimate': instance.jobChargesEstimate,
      'note': instance.note,
      'etaMinutes': instance.etaMinutes,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'status': _postedBidStatusToJson(instance.status),
    };
