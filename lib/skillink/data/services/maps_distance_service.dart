import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/utils/result.dart';

class MapsDistanceService {
  MapsDistanceService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _matrixUrl =
      'https://maps.googleapis.com/maps/api/distancematrix/json';

  Future<Result<int>> drivingEtaMinutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final key = AppConstants.googleMapsApiKey;
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _matrixUrl,
        queryParameters: <String, dynamic>{
          'origins': '$originLat,$originLng',
          'destinations': '$destLat,$destLng',
          'mode': 'driving',
          'key': key,
        },
      );
      final data = res.data;
      if (data == null) {
        return const Failure('Distance Matrix returned empty response.');
      }
      final rows = data['rows'] as List<dynamic>?;
      if (rows == null || rows.isEmpty) {
        return Failure(data['error_message'] as String? ?? 'No route rows.');
      }
      final elements = (rows.first as Map<String, dynamic>)['elements']
          as List<dynamic>?;
      if (elements == null || elements.isEmpty) {
        return const Failure('No route elements.');
      }
      final el = elements.first as Map<String, dynamic>;
      if (el['status'] != 'OK') {
        return Failure(el['status'] as String? ?? 'Route not OK.');
      }
      final duration = el['duration'] as Map<String, dynamic>?;
      final secs = (duration?['value'] as num?)?.toInt();
      if (secs == null) {
        return const Failure('Missing duration value.');
      }
      return Success((secs / 60).ceil().clamp(1, 24 * 60));
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('MapsDistanceService error: $e');
      }
      return Failure('Could not compute travel time.', e);
    }
  }
}
