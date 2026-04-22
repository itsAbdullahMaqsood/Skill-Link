import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/utils/result.dart';

class DirectionsService {
  DirectionsService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _directionsUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  Future<Result<List<LatLng>>> fetchRoute({
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving',
  }) async {
    final key = AppConstants.googleMapsApiKey;
    if (key.isEmpty) {
      return const Failure('Google Maps API key is missing.');
    }

    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _directionsUrl,
        queryParameters: <String, dynamic>{
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': mode,
          'key': key,
        },
      );

      final data = res.data;
      if (data == null) {
        return const Failure('Directions API returned empty response.');
      }

      final status = data['status'] as String?;
      if (status != 'OK') {
        final msg = (data['error_message'] as String?) ??
            'Directions API status: $status';
        if (kDebugMode) {
          debugPrint('[DirectionsService] $msg');
        }
        return Failure(msg);
      }

      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        return const Failure('No route found.');
      }

      final overview =
          (routes.first as Map<String, dynamic>)['overview_polyline']
              as Map<String, dynamic>?;
      final encoded = overview?['points'] as String?;
      if (encoded == null || encoded.isEmpty) {
        return const Failure('Route polyline missing from response.');
      }

      return Success(_decodePolyline(encoded));
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[DirectionsService] Dio error: ${e.message}');
      }
      return Failure(e.message ?? 'Network error fetching directions.');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DirectionsService] Unexpected error: $e');
      }
      return const Failure('Unexpected error fetching directions.');
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final result = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;
    final len = encoded.length;

    while (index < len) {
      int shift = 0;
      int res = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        res |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLat = ((res & 1) != 0) ? ~(res >> 1) : (res >> 1);
      lat += dLat;

      shift = 0;
      res = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        res |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLng = ((res & 1) != 0) ? ~(res >> 1) : (res >> 1);
      lng += dLng;

      result.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return result;
  }
}
