import 'package:freezed_annotation/freezed_annotation.dart';

part 'anomaly.freezed.dart';
part 'anomaly.g.dart';

@freezed
abstract class Anomaly with _$Anomaly {
  const factory Anomaly({
    required String id,
    required String applianceId,
    required String type,
    required String severity,
    required DateTime detectedAt,
    @Default(false) bool read,
    String? message,
    String? applianceName,
    String? suggestedTrade,
  }) = _Anomaly;

  factory Anomaly.fromJson(Map<String, dynamic> json) =>
      _$AnomalyFromJson(json);
}
