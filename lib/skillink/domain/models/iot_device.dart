import 'package:freezed_annotation/freezed_annotation.dart';

part 'iot_device.freezed.dart';
part 'iot_device.g.dart';

@freezed
abstract class IotDevice with _$IotDevice {
  const factory IotDevice({
    required String id,
    required String applianceId,
    required String status,
    DateTime? lastSeen,
  }) = _IotDevice;

  factory IotDevice.fromJson(Map<String, dynamic> json) =>
      _$IotDeviceFromJson(json);
}
