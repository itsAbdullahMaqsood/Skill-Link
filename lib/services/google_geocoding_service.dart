import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleGeocodingService {
  GoogleGeocodingService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<({double lat, double lng})?> forwardGeocode(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return null;
    final key = dotenv.env['GOOGLE_MAPS_API_KEY']?.trim();
    if (key == null ||
        key.isEmpty ||
        key == 'your-google-maps-key-here') {
      return null;
    }
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: <String, dynamic>{
          'address': trimmed,
          'key': key,
        },
      );
      final data = res.data;
      if (data == null) return null;
      final status = data['status'] as String? ?? '';
      if (status != 'OK') return null;
      final results = data['results'];
      if (results is! List || results.isEmpty) return null;
      final first = results.first;
      if (first is! Map<String, dynamic>) return null;
      final geom = first['geometry'];
      if (geom is! Map<String, dynamic>) return null;
      final loc = geom['location'];
      if (loc is! Map<String, dynamic>) return null;
      final lat = (loc['lat'] as num?)?.toDouble();
      final lng = (loc['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      return (lat: lat, lng: lng);
    } on Exception {
      return null;
    }
  }

  Future<String?> reverseGeocode(double latitude, double longitude) async {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY']?.trim();
    if (key == null ||
        key.isEmpty ||
        key == 'your-google-maps-key-here') {
      return null;
    }
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: <String, dynamic>{
          'latlng': '$latitude,$longitude',
          'key': key,
        },
      );
      final data = res.data;
      if (data == null) return null;
      final status = data['status'] as String? ?? '';
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        return null;
      }
      final results = data['results'];
      if (results is! List || results.isEmpty) return null;
      final first = results.first;
      if (first is! Map<String, dynamic>) return null;
      return first['formatted_address'] as String?;
    } on Exception {
      return null;
    }
  }
}
