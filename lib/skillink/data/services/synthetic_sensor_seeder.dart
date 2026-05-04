import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:skilllink/skillink/config/app_constants.dart';

class SeederProgress {
  const SeederProgress({required this.written, required this.total});
  final int written;
  final int total;
}

/// Pushes synthetic V/I/W samples to RTDB `sensorHistory` for baseline training.
class SyntheticSensorSeeder {
  SyntheticSensorSeeder({math.Random? rng}) : _rng = rng ?? math.Random();

  final math.Random _rng;

  static const String _path = 'sensorHistory';

  DatabaseReference _ref() {
    final app = Firebase.app();
    final database = FirebaseDatabase.instanceFor(
      app: app,
      databaseURL: AppConstants.firebaseRtdbUrl,
    );
    return database.ref().child(_path);
  }

  Stream<SeederProgress> seed({
    int sampleCount = 2000,
    Duration spanBack = const Duration(hours: 72),
  }) async* {
    final spanMs = spanBack.inMilliseconds;
    final now = DateTime.now().millisecondsSinceEpoch;
    final timestamps = <int>[
      for (var i = 0; i < sampleCount; i++)
        now - _rng.nextInt(spanMs == 0 ? 1 : spanMs),
    ]..sort();

    final ref = _ref();
    const batchSize = 50;
    var written = 0;

    for (var start = 0; start < sampleCount; start += batchSize) {
      final end = math.min(start + batchSize, sampleCount);
      final batch = <String, dynamic>{};
      for (var i = start; i < end; i++) {
        final t = timestamps[i];
        final v = _clamp(220 + _gaussian(0, 2.0), 212, 230);
        final c = _clamp(0.45 + _gaussian(0, 0.10), 0.10, 0.95);
        final w = v * c;
        batch[t.toString()] = {
          'voltage': v,
          'current': c,
          'power': w,
          'timestamp': t,
        };
      }
      await ref.update(batch);
      written = end;
      yield SeederProgress(written: written, total: sampleCount);
    }
  }

  double _gaussian(double mean, double std) {
    final u1 = _rng.nextDouble().clamp(1e-12, 1.0);
    final u2 = _rng.nextDouble();
    final z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
    return mean + std * z;
  }

  double _clamp(double v, double lo, double hi) {
    if (v < lo) return lo;
    if (v > hi) return hi;
    return v;
  }
}
