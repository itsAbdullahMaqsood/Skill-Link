import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';

/// Listens to the ESP32 writer path on Realtime Database (`sensorData` by default).
///
/// Call [Firebase.initializeApp] in `main` (Android) before use.
class FirebaseRtdbLiveService {
  FirebaseRtdbLiveService();

  final String _databaseUrl = AppConstants.firebaseRtdbUrl;

  DatabaseReference _ref(String childPath) {
    final app = Firebase.app();
    final database = FirebaseDatabase.instanceFor(
      app: app,
      databaseURL: _databaseUrl,
    );
    return database.ref().child(childPath);
  }

  static SensorReading? _parseValue(Object? raw) {
    if (raw is! Map) return null;
    final m = <String, dynamic>{};
    raw.forEach((k, v) {
      m[k.toString()] = v;
    });

    final v = m['voltage'] ?? m['V'];
    final a = m['current'] ?? m['I'] ?? m['amps'];
    final w = m['power'] ?? m['wattage'] ?? m['W'];
    final t = m['timestamp'] ?? m['ts'] ?? m['time'];

    if (v == null || a == null) return null;

    final voltage = v is num ? v.toDouble() : double.tryParse(v.toString());
    final current = a is num ? a.toDouble() : double.tryParse(a.toString());
    if (voltage == null || current == null) return null;

    double? watt;
    if (w is num) {
      watt = w.toDouble();
    } else if (w is String) {
      watt = double.tryParse(w);
    }
    watt ??= (voltage * current).abs();

    final DateTime ts;
    if (t is int) {
      if (t > 2000000000) {
        ts = DateTime.fromMillisecondsSinceEpoch(t);
      } else {
        ts = DateTime.fromMillisecondsSinceEpoch(t * 1000);
      }
    } else {
      ts = DateTime.now();
    }

    return SensorReading(
      voltage: voltage,
      current: current,
      wattage: watt,
      timestamp: ts,
    );
  }

  /// Real-time values under [AppConstants.firebaseEsp32SensorDataPath] (`sensorData`).
  Stream<SensorReading?> watchEsp32SensorData() {
    return _ref(AppConstants.firebaseEsp32SensorDataPath)
        .onValue
        .map((e) => _parseValue(e.snapshot.value));
  }
}
