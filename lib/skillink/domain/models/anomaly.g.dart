// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anomaly.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Anomaly _$AnomalyFromJson(Map<String, dynamic> json) => _Anomaly(
  id: json['id'] as String,
  applianceId: json['applianceId'] as String,
  type: json['type'] as String,
  severity: json['severity'] as String,
  detectedAt: DateTime.parse(json['detectedAt'] as String),
  read: json['read'] as bool? ?? false,
  message: json['message'] as String?,
  applianceName: json['applianceName'] as String?,
  suggestedTrade: json['suggestedTrade'] as String?,
);

Map<String, dynamic> _$AnomalyToJson(_Anomaly instance) => <String, dynamic>{
  'id': instance.id,
  'applianceId': instance.applianceId,
  'type': instance.type,
  'severity': instance.severity,
  'detectedAt': instance.detectedAt.toIso8601String(),
  'read': instance.read,
  'message': instance.message,
  'applianceName': instance.applianceName,
  'suggestedTrade': instance.suggestedTrade,
};
