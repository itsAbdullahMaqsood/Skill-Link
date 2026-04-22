// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iot_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IotDevice _$IotDeviceFromJson(Map<String, dynamic> json) => _IotDevice(
  id: json['id'] as String,
  applianceId: json['applianceId'] as String,
  status: json['status'] as String,
  lastSeen: json['lastSeen'] == null
      ? null
      : DateTime.parse(json['lastSeen'] as String),
);

Map<String, dynamic> _$IotDeviceToJson(_IotDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'applianceId': instance.applianceId,
      'status': instance.status,
      'lastSeen': instance.lastSeen?.toIso8601String(),
    };
