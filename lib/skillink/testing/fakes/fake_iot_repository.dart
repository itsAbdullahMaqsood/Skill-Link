import 'dart:async';
import 'dart:math' as math;

import 'package:skilllink/skillink/data/repositories/iot_repository.dart';
import 'package:skilllink/skillink/data/services/local_notifications_service.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/domain/models/appliance.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';
import 'package:skilllink/skillink/testing/models/sample_appliances.dart';
import 'package:skilllink/skillink/utils/result.dart';

class FakeIotRepository implements IotRepository {
  FakeIotRepository({
    List<Appliance>? seedAppliances,
    Anomaly? seedAnomaly,
    LocalNotificationsService? notifications,
    math.Random? rng,
  })  : _notifications = notifications,
        _rng = rng ?? math.Random(),
        _appliances = [...(seedAppliances ?? SampleAppliances.all)],
        _anomalies = [seedAnomaly ?? SampleAppliances.seededAnomaly()];

  final LocalNotificationsService? _notifications;
  final math.Random _rng;
  final List<Appliance> _appliances;
  final List<Anomaly> _anomalies;

  final Map<String, StreamController<SensorReading>> _liveControllers = {};
  final Map<String, Timer> _liveTimers = {};
  final StreamController<Anomaly> _anomalyStream =
      StreamController<Anomaly>.broadcast();

  static const _latency = Duration(milliseconds: 250);


  @override
  Future<Result<List<Appliance>>> getAppliances() async {
    await Future<void>.delayed(_latency);
    return Success(List.unmodifiable(_appliances));
  }

  @override
  Future<Result<Appliance>> addAppliance(AddApplianceInput input) async {
    await Future<void>.delayed(_latency);
    final appliance = Appliance(
      id: 'appl_${DateTime.now().microsecondsSinceEpoch}',
      userId: 'homeowner_001',
      type: input.type,
      brand: input.brand,
      model: input.model,
      iotDeviceId: input.iotDeviceId,
    );
    _appliances.add(appliance);
    return Success(appliance);
  }


  @override
  Future<Result<List<SensorReading>>> getSensorHistory({
    required String applianceId,
    required SensorHistoryWindow window,
  }) async {
    await Future<void>.delayed(_latency);
    return Success(SampleAppliances.history(
      applianceId: applianceId,
      duration: _durationFor(window),
      points: 60,
    ));
  }

  @override
  Stream<SensorReading> watchLiveSensorData(String deviceId) {
    final ctrl = _liveControllers.putIfAbsent(deviceId, () {
      final controller = StreamController<SensorReading>.broadcast(
        onCancel: () {
        },
      );
      return controller;
    });

    _liveTimers.putIfAbsent(deviceId, () {
      return Timer.periodic(const Duration(milliseconds: 1500), (_) {
        if (ctrl.isClosed) return;
        ctrl.add(_synthesise(deviceId));
      });
    });

    scheduleMicrotask(() {
      if (!ctrl.isClosed) ctrl.add(_synthesise(deviceId));
    });

    return ctrl.stream;
  }

  SensorReading _synthesise(String deviceId) {
    final appliance = _appliances.firstWhere(
      (a) => a.iotDeviceId == deviceId,
      orElse: () => _appliances.first,
    );
    final band = SampleAppliances.nominalBand[appliance.id] ??
        const (voltage: 220, current: 1, wattage: 220);
    double jitter(double base, double pct) =>
        base * (1 + (_rng.nextDouble() - 0.5) * pct);
    return SensorReading(
      voltage: jitter(band.voltage, 0.02),
      current: jitter(band.current, 0.08),
      wattage: jitter(band.wattage, 0.06),
      timestamp: DateTime.now(),
    );
  }


  @override
  Future<Result<List<Anomaly>>> getAnomalies({bool unreadOnly = false}) async {
    await Future<void>.delayed(_latency);
    final filtered = unreadOnly
        ? _anomalies.where((a) => !a.read).toList()
        : [..._anomalies];
    filtered.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return Success(List.unmodifiable(filtered));
  }

  @override
  Future<Result<Anomaly>> getAnomaly(String id) async {
    await Future<void>.delayed(_latency);
    final found = _anomalies.where((a) => a.id == id);
    if (found.isEmpty) return const Failure('Anomaly not found.');
    return Success(found.first);
  }

  @override
  Future<Result<Anomaly?>> getLatestUnreadAnomaly() async {
    final res = await getAnomalies(unreadOnly: true);
    return res.when(
      success: (list) => Success<Anomaly?>(list.isEmpty ? null : list.first),
      failure: (msg, e) => Failure<Anomaly?>(msg, e),
    );
  }

  @override
  Stream<Anomaly> watchAnomalies() => _anomalyStream.stream;

  @override
  Future<Result<Anomaly>> simulateAnomaly({
    required String applianceId,
    required String type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final appliance = _appliances.firstWhere(
      (a) => a.id == applianceId,
      orElse: () => _appliances.first,
    );

    final now = DateTime.now();
    final anomaly = Anomaly(
      id: 'an_${now.microsecondsSinceEpoch}',
      applianceId: applianceId,
      applianceName: _friendlyName(appliance),
      type: type,
      severity: _severityFor(type),
      message: _messageFor(type, appliance),
      detectedAt: now,
      suggestedTrade: _tradeFor(type),
    );

    _anomalies.insert(0, anomaly);
    if (!_anomalyStream.isClosed) _anomalyStream.add(anomaly);

    await _notifications?.showAnomaly(anomaly);

    return Success(anomaly);
  }

  @override
  Future<Result<void>> markAnomalyRead(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final idx = _anomalies.indexWhere((a) => a.id == id);
    if (idx == -1) return const Failure('Anomaly not found.');
    _anomalies[idx] = _anomalies[idx].copyWith(read: true);
    return const Success(null);
  }


  void dispose() {
    for (final t in _liveTimers.values) {
      t.cancel();
    }
    _liveTimers.clear();
    for (final c in _liveControllers.values) {
      c.close();
    }
    _liveControllers.clear();
    if (!_anomalyStream.isClosed) _anomalyStream.close();
  }


  static Duration _durationFor(SensorHistoryWindow w) => switch (w) {
        SensorHistoryWindow.hour => const Duration(hours: 1),
        SensorHistoryWindow.day => const Duration(days: 1),
        SensorHistoryWindow.week => const Duration(days: 7),
      };

  static String _friendlyName(Appliance a) {
    final label = switch (a.type.toLowerCase()) {
      'ac' || 'hvac' => 'AC',
      'fridge' => 'Fridge',
      'heater' => 'Heater',
      'washer' => 'Washing Machine',
      _ => a.type,
    };
    return '${a.brand} $label';
  }

  static String _severityFor(String type) => switch (type) {
        'voltage_spike' => 'high',
        'current_surge' => 'high',
        'over_temperature' => 'medium',
        _ => 'medium',
      };

  static String _tradeFor(String type) => switch (type) {
        'voltage_spike' => 'electrician',
        'current_surge' => 'electrician',
        'over_temperature' => 'hvac',
        _ => 'electrician',
      };

  static String _messageFor(String type, Appliance a) {
    final where = _friendlyName(a);
    return switch (type) {
      'voltage_spike' =>
        'Voltage spiked to 246V on the $where — check the outlet wiring.',
      'current_surge' =>
        'Current surge detected on the $where — consider unplugging it.',
      'over_temperature' =>
        'The $where is running hotter than usual — a quick checkup is wise.',
      _ => 'Anomaly detected on the $where.',
    };
  }
}
