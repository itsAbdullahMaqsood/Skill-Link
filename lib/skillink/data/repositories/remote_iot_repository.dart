import 'package:dio/dio.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/repositories/iot_repository.dart';
import 'package:skilllink/skillink/data/services/api_service.dart';
import 'package:skilllink/skillink/data/services/firebase_rtdb_live_service.dart';
import 'package:skilllink/skillink/data/services/local_notifications_service.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/domain/models/appliance.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';
import 'package:skilllink/skillink/utils/error_mapper.dart';
import 'package:skilllink/skillink/utils/result.dart';

class RemoteIotRepository implements IotRepository {
  RemoteIotRepository({
    required ApiService apiService,
    required LocalNotificationsService notifications,
    required String Function() currentUserId,
    FirebaseRtdbLiveService? rtdbLive,
  })  : _api = apiService,
        _notifications = notifications,
        _userId = currentUserId,
        _rtdb = rtdbLive ?? FirebaseRtdbLiveService();

  final ApiService _api;
  final LocalNotificationsService _notifications;
  // ignore: unused_field
  final String Function() _userId;
  final FirebaseRtdbLiveService _rtdb;

  @override
  Future<Result<List<Appliance>>> getAppliances() async {
    try {
      final res = await _api.get<List<dynamic>>('/appliances');
      final items = (res.data ?? const <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(Appliance.fromJson)
          .toList();
      return Success(items);
    } on DioException catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<Appliance>> addAppliance(AddApplianceInput input) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/appliances',
        data: {
          'type': input.type,
          'brand': input.brand,
          'model': input.model,
          'iotDeviceId': input.iotDeviceId,
        },
      );
      return Success(Appliance.fromJson(res.data!));
    } on DioException catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<List<SensorReading>>> getSensorHistory({
    required String applianceId,
    required SensorHistoryWindow window,
  }) async {
    try {
      final now = DateTime.now();
      final from = now.subtract(_durationFor(window));
      final res = await _api.get<List<dynamic>>(
        '/appliances/$applianceId/history',
        queryParameters: {
          'from': from.toIso8601String(),
          'to': now.toIso8601String(),
        },
      );
      final items = (res.data ?? const <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(SensorReading.fromJson)
          .toList();
      return Success(items);
    } on DioException catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Stream<SensorReading> watchLiveSensorData(String deviceId) {
    if (deviceId == AppConstants.firebaseEsp32SensorDataDeviceId) {
      return _rtdb
          .watchEsp32SensorData()
          .where((r) => r != null)
          .map((r) => r!);
    }
    return const Stream.empty();
  }

  @override
  Future<Result<List<Anomaly>>> getAnomalies({bool unreadOnly = false}) async {
    try {
      final res = await _api.get<List<dynamic>>(
        '/anomalies',
        queryParameters: {if (unreadOnly) 'unread': true},
      );
      final items = (res.data ?? const <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(Anomaly.fromJson)
          .toList();
      return Success(items);
    } on DioException catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<Anomaly>> getAnomaly(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/anomalies/$id');
      return Success(Anomaly.fromJson(res.data!));
    } on DioException catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<Anomaly?>> getLatestUnreadAnomaly() async {
    final result = await getAnomalies(unreadOnly: true);
    return result.when(
      success: (list) => Success<Anomaly?>(list.isEmpty ? null : list.first),
      failure: (msg, e) => Failure<Anomaly?>(msg, e),
    );
  }

  @override
  Stream<Anomaly> watchAnomalies() {
    throw UnimplementedError(
      'Anomaly streaming is not yet wired to the new SkillLink backend.',
    );
  }

  @override
  Future<Result<Anomaly>> simulateAnomaly({
    required String applianceId,
    required String type,
  }) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/anomalies/simulate',
        data: {'applianceId': applianceId, 'type': type},
      );
      final anomaly = Anomaly.fromJson(res.data!);

      await _notifications.showAnomaly(anomaly);
      return Success(anomaly);
    } on DioException catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<void>> markAnomalyRead(String id) async {
    try {
      await _api.patch<void>('/anomalies/$id/read');
      return const Success(null);
    } on DioException catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  static Duration _durationFor(SensorHistoryWindow w) => switch (w) {
        SensorHistoryWindow.hour => const Duration(hours: 1),
        SensorHistoryWindow.day => const Duration(days: 1),
        SensorHistoryWindow.week => const Duration(days: 7),
      };
}
