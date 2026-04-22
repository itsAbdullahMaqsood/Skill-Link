import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/iot_repository.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';

class AlertsState {
  const AlertsState({
    this.isLoading = false,
    this.anomalies = const <Anomaly>[],
    this.errorMessage,
  });

  final bool isLoading;
  final List<Anomaly> anomalies;
  final String? errorMessage;

  int get unreadCount => anomalies.where((a) => !a.read).length;

  AlertsState copyWith({
    bool? isLoading,
    List<Anomaly>? anomalies,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AlertsState(
      isLoading: isLoading ?? this.isLoading,
      anomalies: anomalies ?? this.anomalies,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AlertsViewModel extends StateNotifier<AlertsState> {
  AlertsViewModel(this._ref) : super(const AlertsState(isLoading: true)) {
    refresh();
    _subscribeLive();
  }

  final Ref _ref;
  StreamSubscription<Anomaly>? _liveSub;

  IotRepository get _iot => _ref.read(iotRepositoryProvider);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final res = await _iot.getAnomalies();
    if (!mounted) return;
    res.when(
      success: (list) {
        state = state.copyWith(
          isLoading: false,
          anomalies: _sort(list),
          clearError: true,
        );
      },
      failure: (msg, _) {
        state = state.copyWith(isLoading: false, errorMessage: msg);
      },
    );
  }

  void _subscribeLive() {
    _liveSub = _iot.watchAnomalies().listen((anomaly) {
      if (!mounted) return;
      if (state.anomalies.any((a) => a.id == anomaly.id)) return;
      state = state.copyWith(
        anomalies: _sort([...state.anomalies, anomaly]),
      );
    });
  }

  Future<void> markRead(String id) async {
    final previous = state.anomalies;
    final optimistic = [
      for (final a in previous)
        if (a.id == id) a.copyWith(read: true) else a,
    ];
    state = state.copyWith(anomalies: optimistic);

    final res = await _iot.markAnomalyRead(id);
    if (!mounted) return;
    res.when(
      success: (_) {},
      failure: (msg, _) {
        state = state.copyWith(anomalies: previous, errorMessage: msg);
      },
    );
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  static List<Anomaly> _sort(List<Anomaly> input) {
    final rank = {'high': 0, 'medium': 1, 'low': 2};
    final list = [...input]..sort((a, b) {
        final ra = rank[a.severity] ?? 3;
        final rb = rank[b.severity] ?? 3;
        if (ra != rb) return ra.compareTo(rb);
        return b.detectedAt.compareTo(a.detectedAt);
      });
    return list;
  }

  @override
  void dispose() {
    _liveSub?.cancel();
    super.dispose();
  }
}

final alertsViewModelProvider =
    StateNotifierProvider.autoDispose<AlertsViewModel, AlertsState>((ref) {
  return AlertsViewModel(ref);
});
