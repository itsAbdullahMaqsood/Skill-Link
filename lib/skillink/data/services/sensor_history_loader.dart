import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';

class TrainingLoadProgress {
  const TrainingLoadProgress({
    required this.parsed,
    required this.total,
    this.samples,
  });

  final int parsed;
  final int total;
  final List<SensorReading>? samples;

  bool get done => samples != null;
}

class SensorHistoryLoader {
  SensorHistoryLoader();

  static const String _path = 'sensorHistory';

  DatabaseReference _ref() {
    final app = Firebase.app();
    final database = FirebaseDatabase.instanceFor(
      app: app,
      databaseURL: AppConstants.firebaseRtdbUrl,
    );
    return database.ref().child(_path);
  }

  Stream<TrainingLoadProgress> load() async* {
    final snap = await _ref().orderByKey().get();
    final value = snap.value;
    if (value is! Map) {
      yield const TrainingLoadProgress(parsed: 0, total: 0, samples: []);
      return;
    }
    final entries = value.entries.toList();
    final total = entries.length;
    final out = <SensorReading>[];
    var parsed = 0;
    for (final e in entries) {
      final r = parseReading(e.value, fallbackKey: e.key);
      if (r != null) out.add(r);
      parsed++;
      if (parsed % 100 == 0) {
        yield TrainingLoadProgress(parsed: parsed, total: total);
      }
    }
    out.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    yield TrainingLoadProgress(parsed: parsed, total: total, samples: out);
  }

  /// Parse one RTDB child into a [SensorReading]. Tolerant of the same key
  /// variants accepted by [FirebaseRtdbLiveService].
  static SensorReading? parseReading(Object? raw, {Object? fallbackKey}) {
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

    DateTime ts;
    if (t is int) {
      ts = t > 2000000000
          ? DateTime.fromMillisecondsSinceEpoch(t)
          : DateTime.fromMillisecondsSinceEpoch(t * 1000);
    } else if (fallbackKey is String) {
      final n = int.tryParse(fallbackKey);
      ts = n == null
          ? DateTime.now()
          : (n > 2000000000
              ? DateTime.fromMillisecondsSinceEpoch(n)
              : DateTime.fromMillisecondsSinceEpoch(n * 1000));
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
}
