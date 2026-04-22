import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/domain/models/appliance.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';
import 'package:skilllink/skillink/utils/result.dart';

class AddApplianceInput {
  const AddApplianceInput({
    required this.type,
    required this.brand,
    required this.model,
    required this.iotDeviceId,
  });

  final String type;
  final String brand;
  final String model;
  final String iotDeviceId;
}

enum SensorHistoryWindow { hour, day, week }

abstract class IotRepository {
  Future<Result<List<Appliance>>> getAppliances();

  Future<Result<Appliance>> addAppliance(AddApplianceInput input);

  Future<Result<List<SensorReading>>> getSensorHistory({
    required String applianceId,
    required SensorHistoryWindow window,
  });

  Stream<SensorReading> watchLiveSensorData(String deviceId);

  Future<Result<List<Anomaly>>> getAnomalies({bool unreadOnly = false});

  Future<Result<Anomaly>> getAnomaly(String id);

  Future<Result<Anomaly?>> getLatestUnreadAnomaly();

  Stream<Anomaly> watchAnomalies();

  Future<Result<Anomaly>> simulateAnomaly({
    required String applianceId,
    required String type,
  });

  Future<Result<void>> markAnomalyRead(String id);
}
