import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/repositories/iot_repository.dart';
import 'package:skilllink/skillink/data/services/baseline_anomaly_detector.dart';
import 'package:skilllink/skillink/data/services/firebase_rtdb_live_service.dart';
import 'package:skilllink/skillink/data/services/local_notifications_service.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/domain/models/appliance.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';

class LiveAnomalyMonitor {
  LiveAnomalyMonitor({
    required FirebaseRtdbLiveService rtdb,
    required IotRepository iot,
    required LocalNotificationsService notifications,
    required BaselineModel? Function() modelGetter,
    Duration cooldown = const Duration(seconds: 60),
    int debounceK = 3,
  })  : _rtdb = rtdb,
        _iot = iot,
        _notifications = notifications,
        _modelGetter = modelGetter,
        _cooldown = cooldown,
        _debounceK = debounceK;

  final FirebaseRtdbLiveService _rtdb;
  final IotRepository _iot;
  final LocalNotificationsService _notifications;
  final BaselineModel? Function() _modelGetter;
  final Duration _cooldown;
  final int _debounceK;

  StreamSubscription<SensorReading?>? _sub;
  DetectorState _state = DetectorState();
  final Map<String, int> _counters = {};
  final Map<String, DateTime> _lastFire = {};
  Appliance? _cachedAppliance;
  bool _running = false;

  Future<void> start() async {
    if (_running) return;
    _running = true;
    _state = DetectorState();
    _counters.clear();

    final res = await _iot.getAppliances();
    res.when(
      success: (list) {
        _cachedAppliance = list.firstWhere(
          (a) =>
              a.iotDeviceId == AppConstants.firebaseEsp32SensorDataDeviceId,
          orElse: () => list.isEmpty
              ? const Appliance(
                  id: 'esp32',
                  userId: '',
                  type: 'sensor',
                  brand: 'ESP32',
                  model: 'Smart plug',
                  iotDeviceId:
                      AppConstants.firebaseEsp32SensorDataDeviceId,
                )
              : list.first,
        );
      },
      failure: (_, _) {},
    );

    _sub = _rtdb.watchEsp32SensorData().listen(_onReading);
  }

  Future<void> stop() async {
    _running = false;
    await _sub?.cancel();
    _sub = null;
  }

  void _onReading(SensorReading? reading) {
    if (reading == null) return;
    final model = _modelGetter();
    if (model == null) return;

    final verdict =
        BaselineAnomalyDetector.evaluate(reading, model, _state);
    if (verdict == null) {
      // Decay all counters by 1.
      for (final k in _counters.keys.toList()) {
        final v = _counters[k]! - 1;
        if (v <= 0) {
          _counters.remove(k);
        } else {
          _counters[k] = v;
        }
      }
      return;
    }

    final type = verdict.type;
    final next = (_counters[type] ?? 0) + 1;
    _counters[type] = next;
    if (next < _debounceK) return;

    final last = _lastFire[type];
    if (last != null && DateTime.now().difference(last) < _cooldown) {
      return;
    }

    _fire(verdict, reading);
    _counters[type] = 0;
    _lastFire[type] = DateTime.now();
  }

  Future<void> _fire(AnomalyVerdict verdict, SensorReading reading) async {
    final appliance = _cachedAppliance;
    final now = DateTime.now();
    final anomaly = Anomaly(
      id: 'an_${now.microsecondsSinceEpoch}',
      applianceId: appliance?.id ?? 'esp32',
      applianceName:
          appliance == null ? 'ESP32 smart monitor' : _friendlyName(appliance),
      type: verdict.type,
      severity: verdict.severity,
      message: verdict.message,
      detectedAt: now,
      suggestedTrade: 'electrician',
    );

    try {
      _iot.recordDetectedAnomaly(anomaly);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LiveAnomalyMonitor.recordDetectedAnomaly failed: $e');
      }
    }
    await _notifications.showAnomaly(anomaly);
  }

  static String _friendlyName(Appliance a) {
    final t = a.type.toLowerCase();
    final label = switch (t) {
      'ac' || 'hvac' => 'AC',
      'fridge' => 'Fridge',
      'heater' => 'Heater',
      'washer' => 'Washing Machine',
      'sensor' => 'Smart monitor',
      _ => a.type,
    };
    return '${a.brand} $label';
  }
}
