// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appliance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Appliance _$ApplianceFromJson(Map<String, dynamic> json) => _Appliance(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: json['type'] as String,
  brand: json['brand'] as String,
  model: json['model'] as String,
  iotDeviceId: json['iotDeviceId'] as String?,
);

Map<String, dynamic> _$ApplianceToJson(_Appliance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'brand': instance.brand,
      'model': instance.model,
      'iotDeviceId': instance.iotDeviceId,
    };
