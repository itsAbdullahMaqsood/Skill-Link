import 'package:skilllink/skillink/data/services/geocoding_cache.dart';
import 'package:skilllink/skillink/utils/haversine.dart';

class EtaResult {
  const EtaResult({
    required this.distanceKm,
    required this.minutes,
  });

  final double distanceKm;
  final int minutes;
}

class EtaService {
  EtaService({required GeocodingCache geocoding})
      : _geocoding = geocoding;

  final GeocodingCache _geocoding;

  static const double _avgUrbanSpeedKmh = 25.0;

  /// Multiplicative correction applied to the great-circle (haversine)
  /// distance to approximate real road distance in dense urban networks.
  /// 1.4 is the typical "circuity factor" reported in transport literature
  /// for cities; without it the badge under-estimates by ~30–40%.
  static const double _roadCorrectionFactor = 1.4;

  Future<EtaResult?> betweenAddresses(
    String fromAddress,
    String toAddress,
  ) async {
    final from = await _geocoding.resolve(fromAddress);
    final to = await _geocoding.resolve(toAddress);
    if (from == null || to == null) return null;
    return betweenLatLng(from.lat, from.lng, to.lat, to.lng);
  }

  Future<EtaResult?> fromLatLngToAddress({
    required double fromLat,
    required double fromLng,
    required String toAddress,
  }) async {
    final to = await _geocoding.resolve(toAddress);
    if (to == null) return null;
    return betweenLatLng(fromLat, fromLng, to.lat, to.lng);
  }

  EtaResult betweenLatLng(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    final straightLineKm = haversineKm(fromLat, fromLng, toLat, toLng);
    final roadKm = straightLineKm * _roadCorrectionFactor;
    final minutes = (roadKm / _avgUrbanSpeedKmh) * 60.0;
    return EtaResult(
      distanceKm: roadKm,
      minutes: minutes.ceil().clamp(1, 60 * 24),
    );
  }
}
