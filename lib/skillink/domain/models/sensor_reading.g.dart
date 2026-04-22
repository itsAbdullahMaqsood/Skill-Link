// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SensorReading _$SensorReadingFromJson(Map<String, dynamic> json) =>
    _SensorReading(
      voltage: (json['voltage'] as num).toDouble(),
      current: (json['current'] as num).toDouble(),
      wattage: (json['wattage'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$SensorReadingToJson(_SensorReading instance) =>
    <String, dynamic>{
      'voltage': instance.voltage,
      'current': instance.current,
      'wattage': instance.wattage,
      'timestamp': instance.timestamp.toIso8601String(),
    };
