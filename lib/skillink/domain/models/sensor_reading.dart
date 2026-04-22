import 'package:freezed_annotation/freezed_annotation.dart';

part 'sensor_reading.freezed.dart';
part 'sensor_reading.g.dart';

@freezed
abstract class SensorReading with _$SensorReading {
  const factory SensorReading({
    required double voltage,
    required double current,
    required double wattage,
    required DateTime timestamp,
  }) = _SensorReading;

  factory SensorReading.fromJson(Map<String, dynamic> json) =>
      _$SensorReadingFromJson(json);
}
