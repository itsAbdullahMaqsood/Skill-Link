import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/services/baseline_anomaly_detector.dart';

enum TrainingPhase { idle, seeding, loading, fitting, done, error }

@immutable
class TrainingState {
  const TrainingState({
    this.phase = TrainingPhase.idle,
    this.progress = 0,
    this.total = 0,
    this.model,
    this.errorMessage,
  });

  final TrainingPhase phase;
  final int progress;
  final int total;
  final BaselineModel? model;
  final String? errorMessage;

  TrainingState copyWith({
    TrainingPhase? phase,
    int? progress,
    int? total,
    BaselineModel? model,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrainingState(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      total: total ?? this.total,
      model: model ?? this.model,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BaselineTrainingViewModel extends StateNotifier<TrainingState> {
  BaselineTrainingViewModel(this._ref) : super(const TrainingState());

  final Ref _ref;

  Future<void> seedTrainingData({int sampleCount = 2000}) async {
    state = state.copyWith(
      phase: TrainingPhase.seeding,
      progress: 0,
      total: sampleCount,
      clearError: true,
    );
    try {
      final seeder = _ref.read(syntheticSensorSeederProvider);
      await for (final p in seeder.seed(sampleCount: sampleCount)) {
        state = state.copyWith(
          progress: p.written,
          total: p.total,
          phase: TrainingPhase.seeding,
        );
      }
      // Fresh data on RTDB; drop the cached samples so the next read refetches.
      _ref.invalidate(cachedTrainingSamplesProvider);
      state = state.copyWith(phase: TrainingPhase.idle);
    } catch (e) {
      state = state.copyWith(
        phase: TrainingPhase.error,
        errorMessage: 'Seeding failed: $e',
      );
    }
  }

  Future<void> trainFromRtdb() async {
    state = state.copyWith(
      phase: TrainingPhase.loading,
      progress: 0,
      total: 0,
      clearError: true,
    );
    try {
      // Read through the cached provider so the chart widgets and the trainer
      // share a single RTDB fetch. If the cache is already warm this is
      // effectively free.
      final samples = await _ref.read(cachedTrainingSamplesProvider.future);
      if (samples.length < 30) {
        state = state.copyWith(
          phase: TrainingPhase.error,
          errorMessage:
              'Not enough samples in sensorHistory (need ≥30, got '
              '${samples.length}). Seed first.',
        );
        return;
      }
      state = state.copyWith(
        phase: TrainingPhase.fitting,
        progress: samples.length,
        total: samples.length,
      );
      final model = BaselineAnomalyDetector.fit(samples);
      state = state.copyWith(
        phase: TrainingPhase.done,
        model: model,
      );
    } catch (e) {
      state = state.copyWith(
        phase: TrainingPhase.error,
        errorMessage: 'Training failed: $e',
      );
    }
  }

  Future<void> activate() async {
    final model = state.model;
    if (model == null) return;
    final storage = _ref.read(baselineModelStorageProvider);
    await storage.save(model);
    _ref.invalidate(baselineModelProvider);
  }

  Future<void> clearTrained() async {
    final storage = _ref.read(baselineModelStorageProvider);
    await storage.clear();
    state = const TrainingState();
    _ref.invalidate(baselineModelProvider);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final baselineTrainingViewModelProvider =
    StateNotifierProvider<BaselineTrainingViewModel, TrainingState>(
  (ref) => BaselineTrainingViewModel(ref),
);
