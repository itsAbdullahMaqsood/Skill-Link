import 'package:dio/dio.dart';
import 'package:skilllink/skillink/data/repositories/anomaly_repository.dart';
import 'package:skilllink/skillink/data/services/api_service.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/utils/error_mapper.dart';
import 'package:skilllink/skillink/utils/result.dart';

class RemoteAnomalyRepository implements AnomalyRepository {
  RemoteAnomalyRepository({required ApiService apiService}) : _api = apiService;

  final ApiService _api;

  @override
  Future<Result<Anomaly?>> getLatestAnomaly() async {
    try {
      final res = await _api.get<List<dynamic>>(
        '/anomalies',
        queryParameters: {'limit': 1, 'read': false},
      );
      final items = (res.data ?? const <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(Anomaly.fromJson)
          .toList();
      return Success(items.isEmpty ? null : items.first);
    } on DioException catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }
}
