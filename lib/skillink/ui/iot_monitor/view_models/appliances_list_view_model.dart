import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/iot_repository.dart';
import 'package:skilllink/skillink/domain/models/appliance.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';

class AppliancesListState {
  const AppliancesListState({
    this.isLoading = false,
    this.appliances = const <Appliance>[],
    this.liveByDeviceId = const <String, SensorReading>{},
    this.errorMessage,
  });

  final bool isLoading;
  final List<Appliance> appliances;
  final Map<String, SensorReading> liveByDeviceId;

  final String? errorMessage;

  AppliancesListState copyWith({
    bool? isLoading,
    List<Appliance>? appliances,
    Map<String, SensorReading>? liveByDeviceId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppliancesListState(
      isLoading: isLoading ?? this.isLoading,
      appliances: appliances ?? this.appliances,
      liveByDeviceId: liveByDeviceId ?? this.liveByDeviceId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AppliancesListViewModel extends StateNotifier<AppliancesListState> {
  AppliancesListViewModel(this._ref)
      : super(const AppliancesListState(isLoading: true)) {
    refresh();
  }

  final Ref _ref;

  final Map<String, StreamSubscription<SensorReading>> _liveSubs = {};

  IotRepository get _iot => _ref.read(iotRepositoryProvider);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final res = await _iot.getAppliances();
    if (!mounted) return;
    res.when(
      success: (list) {
        state = state.copyWith(
          isLoading: false,
          appliances: list,
          clearError: true,
        );
        _syncLiveSubscriptions(list);
      },
      failure: (msg, _) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: msg,
        );
      },
    );
  }

  Future<String?> addAppliance(AddApplianceInput input) async {
    final res = await _iot.addAppliance(input);
    if (!mounted) {
      return res.when(success: (_) => null, failure: (msg, _) => msg);
    }
    return res.when(
      success: (_) async {
        await refresh();
        return null;
      },
      failure: (msg, _) => msg,
    );
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  void _syncLiveSubscriptions(List<Appliance> appliances) {
    final wantedDevices = {
      for (final a in appliances)
        if (a.iotDeviceId != null && a.iotDeviceId!.isNotEmpty) a.iotDeviceId!,
    };

    for (final device in _liveSubs.keys.toList()) {
      if (!wantedDevices.contains(device)) {
        _liveSubs.remove(device)?.cancel();
      }
    }

    for (final device in wantedDevices) {
      if (_liveSubs.containsKey(device)) continue;
      _liveSubs[device] = _iot.watchLiveSensorData(device).listen((reading) {
        if (!mounted) return;
        state = state.copyWith(
          liveByDeviceId: {
            ...state.liveByDeviceId,
            device: reading,
          },
        );
      });
    }
  }

  @override
  void dispose() {
    for (final sub in _liveSubs.values) {
      sub.cancel();
    }
    _liveSubs.clear();
    super.dispose();
  }
}

final appliancesListViewModelProvider = StateNotifierProvider.autoDispose<
    AppliancesListViewModel, AppliancesListState>((ref) {
  return AppliancesListViewModel(ref);
});
