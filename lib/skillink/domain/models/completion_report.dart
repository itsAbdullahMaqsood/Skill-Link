import 'package:freezed_annotation/freezed_annotation.dart';

part 'completion_report.freezed.dart';
part 'completion_report.g.dart';

@freezed
abstract class CompletionReport with _$CompletionReport {
  const factory CompletionReport({
    required String jobId,
    required DateTime createdAt,
    double? homeownerAmount,
    DateTime? homeownerSubmittedAt,
    double? workerAmount,
    DateTime? workerSubmittedAt,
    @Default(false) bool flagged,
    String? flaggedReason,
  }) = _CompletionReport;

  factory CompletionReport.fromJson(Map<String, dynamic> json) =>
      _$CompletionReportFromJson(json);
}

extension CompletionReportX on CompletionReport {
  bool get homeownerSubmitted => homeownerAmount != null;
  bool get workerSubmitted => workerAmount != null;
  bool get bothSubmitted => homeownerSubmitted && workerSubmitted;
}
