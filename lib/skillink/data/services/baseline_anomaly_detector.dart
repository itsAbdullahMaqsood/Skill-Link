import 'dart:collection';
import 'dart:math' as math;

import 'package:skilllink/skillink/domain/models/sensor_reading.dart';

/// Immutable trained baseline. Hand-written JSON to avoid build_runner thrash.
class BaselineModel {
  const BaselineModel({
    required this.voltageMean,
    required this.voltageStd,
    required this.voltageP01,
    required this.voltageP99,
    required this.voltageMaxRate,
    required this.currentMean,
    required this.currentStd,
    required this.currentP01,
    required this.currentP99,
    required this.currentMaxRate,
    required this.covVV,
    required this.covVI,
    required this.covII,
    required this.invCovVV,
    required this.invCovVI,
    required this.invCovII,
    required this.mahalanobisChi2Threshold,
    required this.sampleCount,
    required this.trainedAt,
    required this.trainingDurationMs,
  });

  final double voltageMean;
  final double voltageStd;
  final double voltageP01;
  final double voltageP99;
  final double voltageMaxRate;

  final double currentMean;
  final double currentStd;
  final double currentP01;
  final double currentP99;
  final double currentMaxRate;

  final double covVV;
  final double covVI;
  final double covII;

  final double invCovVV;
  final double invCovVI;
  final double invCovII;

  final double mahalanobisChi2Threshold;
  final int sampleCount;
  final DateTime trainedAt;
  final int trainingDurationMs;

  Map<String, dynamic> toJson() => {
        'voltageMean': voltageMean,
        'voltageStd': voltageStd,
        'voltageP01': voltageP01,
        'voltageP99': voltageP99,
        'voltageMaxRate': voltageMaxRate,
        'currentMean': currentMean,
        'currentStd': currentStd,
        'currentP01': currentP01,
        'currentP99': currentP99,
        'currentMaxRate': currentMaxRate,
        'covVV': covVV,
        'covVI': covVI,
        'covII': covII,
        'invCovVV': invCovVV,
        'invCovVI': invCovVI,
        'invCovII': invCovII,
        'mahalanobisChi2Threshold': mahalanobisChi2Threshold,
        'sampleCount': sampleCount,
        'trainedAt': trainedAt.toIso8601String(),
        'trainingDurationMs': trainingDurationMs,
      };

  factory BaselineModel.fromJson(Map<String, dynamic> j) => BaselineModel(
        voltageMean: (j['voltageMean'] as num).toDouble(),
        voltageStd: (j['voltageStd'] as num).toDouble(),
        voltageP01: (j['voltageP01'] as num).toDouble(),
        voltageP99: (j['voltageP99'] as num).toDouble(),
        voltageMaxRate: (j['voltageMaxRate'] as num).toDouble(),
        currentMean: (j['currentMean'] as num).toDouble(),
        currentStd: (j['currentStd'] as num).toDouble(),
        currentP01: (j['currentP01'] as num).toDouble(),
        currentP99: (j['currentP99'] as num).toDouble(),
        currentMaxRate: (j['currentMaxRate'] as num).toDouble(),
        covVV: (j['covVV'] as num).toDouble(),
        covVI: (j['covVI'] as num).toDouble(),
        covII: (j['covII'] as num).toDouble(),
        invCovVV: (j['invCovVV'] as num).toDouble(),
        invCovVI: (j['invCovVI'] as num).toDouble(),
        invCovII: (j['invCovII'] as num).toDouble(),
        mahalanobisChi2Threshold:
            (j['mahalanobisChi2Threshold'] as num).toDouble(),
        sampleCount: (j['sampleCount'] as num).toInt(),
        trainedAt: DateTime.parse(j['trainedAt'] as String),
        trainingDurationMs: (j['trainingDurationMs'] as num).toInt(),
      );
}

class AnomalyVerdict {
  const AnomalyVerdict({
    required this.type,
    required this.severity,
    required this.message,
  });

  final String type;
  final String severity;
  final String message;
}

class DetectorState {
  DetectorState();

  SensorReading? lastReading;
  final Queue<double> voltageRingBuffer = Queue<double>();
  static const int ringCapacity = 30;

  void pushVoltage(double v) {
    voltageRingBuffer.addLast(v);
    while (voltageRingBuffer.length > ringCapacity) {
      voltageRingBuffer.removeFirst();
    }
  }

  bool get ringFull => voltageRingBuffer.length >= ringCapacity;

  double ringStd() {
    if (voltageRingBuffer.isEmpty) return 0;
    final n = voltageRingBuffer.length;
    double sum = 0;
    for (final v in voltageRingBuffer) {
      sum += v;
    }
    final mean = sum / n;
    double m2 = 0;
    for (final v in voltageRingBuffer) {
      final d = v - mean;
      m2 += d * d;
    }
    return math.sqrt(m2 / n);
  }
}

class BaselineAnomalyDetector {
  BaselineAnomalyDetector._();

  /// Fit model from samples. Single-pass mean/std (Welford), sorted percentile.
  static BaselineModel fit(List<SensorReading> samples) {
    final start = DateTime.now();
    if (samples.length < 30) {
      throw StateError(
        'Need at least 30 samples to fit baseline (got ${samples.length}).',
      );
    }

    final sorted = [...samples]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final n = sorted.length;

    double meanV = 0, meanI = 0;
    double m2V = 0, m2I = 0;
    int k = 0;
    for (final r in sorted) {
      k++;
      final dv = r.voltage - meanV;
      meanV += dv / k;
      m2V += dv * (r.voltage - meanV);
      final di = r.current - meanI;
      meanI += di / k;
      m2I += di * (r.current - meanI);
    }
    final stdV = math.sqrt(m2V / n);
    final stdI = math.sqrt(m2I / n);

    final vSorted = sorted.map((r) => r.voltage).toList()..sort();
    final iSorted = sorted.map((r) => r.current).toList()..sort();

    double percentile(List<double> a, double p) {
      if (a.isEmpty) return 0;
      final idx = (p * (a.length - 1)).round().clamp(0, a.length - 1);
      return a[idx];
    }

    final vP01 = percentile(vSorted, 0.01);
    final vP99 = percentile(vSorted, 0.99);
    final iP01 = percentile(iSorted, 0.01);
    final iP99 = percentile(iSorted, 0.99);

    final vRates = <double>[];
    final iRates = <double>[];
    for (var k = 1; k < sorted.length; k++) {
      final dt = sorted[k].timestamp
              .difference(sorted[k - 1].timestamp)
              .inMilliseconds /
          1000.0;
      if (dt <= 0) continue;
      vRates.add((sorted[k].voltage - sorted[k - 1].voltage).abs() / dt);
      iRates.add((sorted[k].current - sorted[k - 1].current).abs() / dt);
    }
    vRates.sort();
    iRates.sort();
    final vMaxRate = vRates.isEmpty ? 0.0 : percentile(vRates, 0.99);
    final iMaxRate = iRates.isEmpty ? 0.0 : percentile(iRates, 0.99);

    double sumVV = 0, sumVI = 0, sumII = 0;
    for (final r in sorted) {
      final dv = r.voltage - meanV;
      final di = r.current - meanI;
      sumVV += dv * dv;
      sumVI += dv * di;
      sumII += di * di;
    }
    var covVV = sumVV / n;
    var covVI = sumVI / n;
    var covII = sumII / n;

    var det = covVV * covII - covVI * covVI;
    if (det <= 1e-9) {
      covVV += 1e-6;
      covII += 1e-6;
      det = covVV * covII - covVI * covVI;
    }
    final invCovVV = covII / det;
    final invCovII = covVV / det;
    final invCovVI = -covVI / det;

    return BaselineModel(
      voltageMean: meanV,
      voltageStd: stdV,
      voltageP01: vP01,
      voltageP99: vP99,
      voltageMaxRate: vMaxRate,
      currentMean: meanI,
      currentStd: stdI,
      currentP01: iP01,
      currentP99: iP99,
      currentMaxRate: iMaxRate,
      covVV: covVV,
      covVI: covVI,
      covII: covII,
      invCovVV: invCovVV,
      invCovVI: invCovVI,
      invCovII: invCovII,
      mahalanobisChi2Threshold: 9.21,
      sampleCount: n,
      trainedAt: DateTime.now(),
      trainingDurationMs:
          DateTime.now().difference(start).inMilliseconds,
    );
  }

  /// Evaluate one reading against the model. Updates [state] in-place.
  /// Returns first-firing layer in priority order, or null.
  static AnomalyVerdict? evaluate(
    SensorReading reading,
    BaselineModel m,
    DetectorState state,
  ) {
    final v = reading.voltage;
    final i = reading.current;

    final last = state.lastReading;
    state.lastReading = reading;
    state.pushVoltage(v);

    // Layer 1 — 3σ envelope.
    final vHi = m.voltageMean + 3 * m.voltageStd;
    final vLo = m.voltageMean - 3 * m.voltageStd;
    final iHi = m.currentMean + 3 * m.currentStd;
    final iLo = m.currentMean - 3 * m.currentStd;

    if (v > vHi) {
      return AnomalyVerdict(
        type: 'voltage_spike',
        severity: 'high',
        message:
            'Voltage spike: ${v.toStringAsFixed(1)}V exceeds learnt μ+3σ of '
            '${vHi.toStringAsFixed(1)}V (μ=${m.voltageMean.toStringAsFixed(1)}V, '
            'σ=${m.voltageStd.toStringAsFixed(2)}V).',
      );
    }
    if (v < vLo) {
      return AnomalyVerdict(
        type: 'voltage_sag',
        severity: 'high',
        message:
            'Voltage sag: ${v.toStringAsFixed(1)}V below learnt μ-3σ of '
            '${vLo.toStringAsFixed(1)}V.',
      );
    }
    if (i > iHi) {
      return AnomalyVerdict(
        type: 'current_surge',
        severity: 'high',
        message:
            'Current surge: ${i.toStringAsFixed(2)}A exceeds learnt μ+3σ of '
            '${iHi.toStringAsFixed(2)}A.',
      );
    }
    if (i < iLo) {
      return AnomalyVerdict(
        type: 'current_drop',
        severity: 'medium',
        message:
            'Unexpected load drop: ${i.toStringAsFixed(2)}A below learnt μ-3σ '
            'of ${iLo.toStringAsFixed(2)}A.',
      );
    }

    // Layer 2 — rate of change.
    if (last != null) {
      final dt = reading.timestamp
              .difference(last.timestamp)
              .inMilliseconds /
          1000.0;
      if (dt > 0) {
        final dv = (v - last.voltage).abs() / dt;
        final threshold = m.voltageMaxRate * 1.5;
        if (threshold > 0 && dv > threshold) {
          return AnomalyVerdict(
            type: 'voltage_flicker',
            severity: 'medium',
            message:
                'Voltage flicker: |Δv|/Δt=${dv.toStringAsFixed(2)} V/s vs '
                'learnt 99th-pct of ${m.voltageMaxRate.toStringAsFixed(2)} V/s.',
          );
        }
      }
    }

    // Layer 3 — rolling-window σ.
    if (state.ringFull) {
      final liveStd = state.ringStd();
      if (m.voltageStd > 0 && liveStd > 3 * m.voltageStd) {
        return AnomalyVerdict(
          type: 'voltage_instability',
          severity: 'medium',
          message:
              'Voltage instability: σ_live=${liveStd.toStringAsFixed(2)}V vs '
              'learnt σ=${m.voltageStd.toStringAsFixed(2)}V (window=30).',
        );
      }
    }

    // Layer 4 — Mahalanobis on (V, I).
    final dv = v - m.voltageMean;
    final di = i - m.currentMean;
    final d2 = dv * dv * m.invCovVV +
        2 * dv * di * m.invCovVI +
        di * di * m.invCovII;
    if (d2 > m.mahalanobisChi2Threshold) {
      return AnomalyVerdict(
        type: 'abnormal_load_pattern',
        severity: 'high',
        message:
            'Abnormal joint V/I pattern: Mahalanobis d²=${d2.toStringAsFixed(2)} '
            '> χ²(2, 0.99)=${m.mahalanobisChi2Threshold.toStringAsFixed(2)} '
            '(V=${v.toStringAsFixed(1)}V, I=${i.toStringAsFixed(2)}A).',
      );
    }

    return null;
  }
}
