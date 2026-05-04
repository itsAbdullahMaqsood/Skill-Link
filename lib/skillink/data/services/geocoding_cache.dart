import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilllink/services/google_geocoding_service.dart';

/// Cached forward-geocoding for free-text addresses.
///
/// Backed by [SharedPreferences]. Entries expire after [_ttl].
class GeocodingCache {
  GeocodingCache({GoogleGeocodingService? geocoder})
      : _geocoder = geocoder ?? GoogleGeocodingService();

  final GoogleGeocodingService _geocoder;
  final Map<String, ({double lat, double lng})> _memory = {};

  static const _prefsKey = 'skilllink_geocoding_cache_v1';
  static const _ttl = Duration(days: 30);

  String _norm(String s) => s.trim().toLowerCase();

  Future<({double lat, double lng})?> resolve(String address) async {
    final key = _norm(address);
    if (key.isEmpty) return null;

    final mem = _memory[key];
    if (mem != null) return mem;

    final disk = await _readDisk();
    final hit = disk[key];
    if (hit != null) {
      final ts = DateTime.tryParse(hit['ts']?.toString() ?? '');
      final lat = (hit['lat'] as num?)?.toDouble();
      final lng = (hit['lng'] as num?)?.toDouble();
      if (ts != null &&
          lat != null &&
          lng != null &&
          DateTime.now().difference(ts) < _ttl) {
        final v = (lat: lat, lng: lng);
        _memory[key] = v;
        return v;
      }
    }

    final fresh = await _geocoder.forwardGeocode(address);
    if (fresh == null) return null;
    _memory[key] = fresh;
    disk[key] = {
      'lat': fresh.lat,
      'lng': fresh.lng,
      'ts': DateTime.now().toIso8601String(),
    };
    await _writeDisk(disk);
    return fresh;
  }

  Future<void> invalidate(String address) async {
    _memory.remove(_norm(address));
    final disk = await _readDisk();
    if (disk.remove(_norm(address)) != null) {
      await _writeDisk(disk);
    }
  }

  Future<Map<String, dynamic>> _readDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return <String, dynamic>{};
  }

  Future<void> _writeDisk(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }
}
