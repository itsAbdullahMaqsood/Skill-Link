import 'package:freezed_annotation/freezed_annotation.dart';

part 'appliance.freezed.dart';
part 'appliance.g.dart';

@freezed
abstract class Appliance with _$Appliance {
  const factory Appliance({
    required String id,
    required String userId,
    required String type,
    required String brand,
    required String model,
    String? iotDeviceId,
  }) = _Appliance;

  factory Appliance.fromJson(Map<String, dynamic> json) =>
      _$ApplianceFromJson(json);
}
