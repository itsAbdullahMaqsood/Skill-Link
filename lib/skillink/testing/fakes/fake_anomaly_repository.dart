import 'package:skilllink/skillink/data/repositories/anomaly_repository.dart';
import 'package:skilllink/skillink/data/repositories/iot_repository.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/testing/models/sample_appliances.dart';
import 'package:skilllink/skillink/utils/result.dart';

class FakeAnomalyRepository implements AnomalyRepository {
  FakeAnomalyRepository({IotRepository? iot}) : _iot = iot;

  final IotRepository? _iot;

  static const _latency = Duration(milliseconds: 200);

  @override
  Future<Result<Anomaly?>> getLatestAnomaly() async {
    if (_iot != null) return _iot.getLatestUnreadAnomaly();
    await Future<void>.delayed(_latency);
    return Success(SampleAppliances.seededAnomaly());
  }
}
