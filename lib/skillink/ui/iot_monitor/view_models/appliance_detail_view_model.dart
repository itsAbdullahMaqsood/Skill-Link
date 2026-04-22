import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/iot_repository.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/domain/models/appliance.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';
import 'package:skilllink/skillink/utils/result.dart';

class ApplianceDetailState {
  const ApplianceDetailState({
    this.isLoading = true,
    this.appliance,
    this.latestReading,
    this.history = const <SensorReading>[],
    this.historyWindow = SensorHistoryWindow.hour,
    this.anomalies = const <Anomaly>[],
    this.isSimulating = false,
    this.errorMessage,
  });

  final bool isLoading;
  final Appliance? appliance;

  final SensorReading? latestReading;

  final List<SensorReading> history;
  final SensorHistoryWindow historyWindow;

  final List<Anomaly> anomalies;

  final bool isSimulating;

  final String? errorMessage;

  double? get averageWattage {
    if (history.isEmpty) return null;
    final sum = history.fold<double>(0, (s, r) => s + r.wattage);
    return sum / history.length;
  }

  double? get peakWattage {
    if (history.isEmpty) return null;
    return history.map((r) => r.wattage).reduce((a, b) => a > b ? a : b);
  }

  double? estimatedDailyCostPkr({double ratePerKwh = 40}) {
    final avg = averageWattage;
    if (avg == null) return null;
    final dailyKwh = (avg / 1000) * 24;
    return dailyKwh * ratePerKwh;
  }

  ApplianceDetailState copyWith({
    bool? isLoading,
    Appliance? appliance,
    SensorReading? latestReading,
    List<SensorReading>? history,
    SensorHistoryWindow? historyWindow,
    List<Anomaly>? anomalies,
    bool? isSimulating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ApplianceDetailState(
      isLoading: isLoading ?? this.isLoading,
      appliance: appliance ?? this.appliance,
      latestReading: latestReading ?? this.latestReading,
      history: history ?? this.history,
      historyWindow: historyWindow ?? this.historyWindow,
      anomalies: anomalies ?? this.anomalies,
      isSimulating: isSimulating ?? this.isSimulating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ApplianceDetailViewModel extends StateNotifier<ApplianceDetailState> {
  ApplianceDetailViewModel(this._ref, this._applianceId)
      : super(const ApplianceDetailState()) {
    _bootstrap();
  }

  final Ref _ref;
  final String _applianceId;

  StreamSubscription<SensorReading>? _liveSub;
  StreamSubscription<Anomaly>? _anomalySub;

  IotRepository get _iot => _ref.read(iotRepositoryProvider);

  Future<void> _bootstrap() async {
    final results = await Future.wait([
      _iot.getAppliances(),
      _iot.getSensorHistory(
        applianceId: _applianceId,
        window: state.historyWindow,
      ),
      _iot.getAnomalies(),
    ]);

    if (!mounted) return;

    final appliancesRes = results[0] as Result<List<Appliance>>;
    final historyRes = results[1] as Result<List<SensorReading>>;
    final anomaliesRes = results[2] as Result<List<Anomaly>>;

    final appliances = appliancesRes.valueOrNull ?? const <Appliance>[];
    final match = appliances.where((a) => a.id == _applianceId);
    final appliance = match.isEmpty ? null : match.first;

    if (appliance == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: appliancesRes.errorOrNull ?? 'Appliance not found.',
      );
      return;
    }

    final history = historyRes.valueOrNull ?? const <SensorReading>[];
    final allAnomalies = anomaliesRes.valueOrNull ?? const <Anomaly>[];
    final forThis =
        allAnomalies.where((a) => a.applianceId == _applianceId).toList();

    state = state.copyWith(
      isLoading: false,
      appliance: appliance,
      history: history,
      anomalies: forThis,
      errorMessage: historyRes.errorOrNull ?? anomaliesRes.errorOrNull,
    );

    _subscribeLive();
    _subscribeAnomalies();
  }

  void _subscribeLive() {
    final deviceId = state.appliance?.iotDeviceId;
    if (deviceId == null || deviceId.isEmpty) return;
    _liveSub?.cancel();
    _liveSub = _iot.watchLiveSensorData(deviceId).listen((reading) {
      if (!mounted) return;
      state = state.copyWith(latestReading: reading);
    });
  }

  void _subscribeAnomalies() {
    _anomalySub?.cancel();
    _anomalySub = _iot.watchAnomalies().listen((anomaly) {
      if (!mounted) return;
      if (anomaly.applianceId != _applianceId) return;
      final existing = state.anomalies;
      final withoutDupe = existing.where((a) => a.id != anomaly.id).toList();
      state = state.copyWith(anomalies: [anomaly, ...withoutDupe]);
    });
  }

  Future<void> setHistoryWindow(SensorHistoryWindow window) async {
    if (window == state.historyWindow) return;
    state = state.copyWith(historyWindow: window, isLoading: true);
    final res = await _iot.getSensorHistory(
      applianceId: _applianceId,
      window: window,
    );
    if (!mounted) return;
    state = state.copyWith(
      isLoading: false,
      history: res.valueOrNull ?? state.history,
      errorMessage: res.errorOrNull,
    );
  }

  Future<void> retry() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _bootstrap();
  }

  Future<String?> simulateAnomaly({String type = 'voltage_spike'}) async {
    if (state.isSimulating) return null;
    state = state.copyWith(isSimulating: true, clearError: true);

    final res = await _iot.simulateAnomaly(
      applianceId: _applianceId,
      type: type,
    );

    if (!mounted) {
      return res.when(success: (a) => a.id, failure: (_, _) => null);
    }

    return res.when(
      success: (anomaly) {
        state = state.copyWith(isSimulating: false);
        return anomaly.id;
      },
      failure: (msg, _) {
        state = state.copyWith(isSimulating: false, errorMessage: msg);
        return null;
      },
    );
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _liveSub?.cancel();
    _anomalySub?.cancel();
    super.dispose();
  }
}

final applianceDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<ApplianceDetailViewModel, ApplianceDetailState, String>(
  (ref, applianceId) => ApplianceDetailViewModel(ref, applianceId),
);
