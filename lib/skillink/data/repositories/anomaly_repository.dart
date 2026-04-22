import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/utils/result.dart';

abstract class AnomalyRepository {
  Future<Result<Anomaly?>> getLatestAnomaly();
}
