// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompletionReport _$CompletionReportFromJson(Map<String, dynamic> json) =>
    _CompletionReport(
      jobId: json['jobId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      homeownerAmount: (json['homeownerAmount'] as num?)?.toDouble(),
      homeownerSubmittedAt: json['homeownerSubmittedAt'] == null
          ? null
          : DateTime.parse(json['homeownerSubmittedAt'] as String),
      workerAmount: (json['workerAmount'] as num?)?.toDouble(),
      workerSubmittedAt: json['workerSubmittedAt'] == null
          ? null
          : DateTime.parse(json['workerSubmittedAt'] as String),
      flagged: json['flagged'] as bool? ?? false,
      flaggedReason: json['flaggedReason'] as String?,
    );

Map<String, dynamic> _$CompletionReportToJson(_CompletionReport instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'createdAt': instance.createdAt.toIso8601String(),
      'homeownerAmount': instance.homeownerAmount,
      'homeownerSubmittedAt': instance.homeownerSubmittedAt?.toIso8601String(),
      'workerAmount': instance.workerAmount,
      'workerSubmittedAt': instance.workerSubmittedAt?.toIso8601String(),
      'flagged': instance.flagged,
      'flaggedReason': instance.flaggedReason,
    };
