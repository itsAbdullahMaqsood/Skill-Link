import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/services/baseline_anomaly_detector.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/iot_monitor/view_models/baseline_training_view_model.dart';

class BaselineTrainingScreen extends ConsumerWidget {
  const BaselineTrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(baselineTrainingViewModelProvider);
    final vm = ref.read(baselineTrainingViewModelProvider.notifier);

    ref.listen<TrainingState>(baselineTrainingViewModelProvider, (prev, next) {
      final msg = next.errorMessage;
      if (msg == null || msg == prev?.errorMessage) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      vm.clearError();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Train baseline', style: AppTypography.headlineMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ProgressBar(state: state),
          const SizedBox(height: 16),
          _VoltageChart(state: state),
          const SizedBox(height: 16),
          _StatsGrid(model: state.model),
          const SizedBox(height: 16),
          _MahalanobisChart(state: state),
          const SizedBox(height: 24),
          _Buttons(state: state, vm: vm),
        ],
      ),
    );
  }
}

class _PhaseChips extends StatelessWidget {
  const _PhaseChips({required this.state});
  final TrainingState state;

  @override
  Widget build(BuildContext context) {
    final fraction = state.total == 0 ? 0.0 : state.progress / state.total;
    final isLoading =
        state.phase == TrainingPhase.loading ||
        state.phase == TrainingPhase.fitting;
    final t = isLoading ? 1.0 : fraction;
    return Row(
      children: [
        for (var i = 1; i <= 3; i++) ...[
          Expanded(
            child: _Chip(label: 'Day $i', filled: t >= i / 3),
          ),
          if (i < 3) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.filled});
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final color = filled ? AppColors.success : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: filled
            ? AppColors.success.withValues(alpha: 0.10)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            filled ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.labelMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.state});
  final TrainingState state;

  @override
  Widget build(BuildContext context) {
    final phase = state.phase;
    String label;
    switch (phase) {
      case TrainingPhase.seeding:
        label = 'Seeding ${state.progress}/${state.total}';
        break;
      case TrainingPhase.loading:
        label =
            'Loading ${state.progress}${state.total > 0 ? '/${state.total}' : ''}';
        break;
      case TrainingPhase.fitting:
        label = 'Fitting baseline…';
        break;
      case TrainingPhase.done:
        label =
            'Baseline trained on ${state.model?.sampleCount ?? 0} samples '
            '(${state.model?.trainingDurationMs ?? 0} ms)';
        break;
      case TrainingPhase.error:
        label = state.errorMessage ?? 'Error';
        break;
      case TrainingPhase.idle:
        label = 'Ready';
        break;
    }
    final progress = state.total == 0 ? null : state.progress / state.total;
    final indeterminate = phase == TrainingPhase.fitting;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: indeterminate ? null : progress,
            backgroundColor: AppColors.divider,
          ),
        ),
      ],
    );
  }
}

class _VoltageChart extends ConsumerWidget {
  const _VoltageChart({required this.state});
  final TrainingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samplesAsync = ref.watch(cachedTrainingSamplesProvider);
    final model = state.model;
    return samplesAsync.when(
      loading: () => _ChartCard(
        title: 'Voltage timeline',
        child: SizedBox(
          height: 180,
          child: Center(
            child: Text(
              'Loading samples from sensorHistory…',
              style: AppTypography.bodySmall,
            ),
          ),
        ),
      ),
      error: (e, _) => _ChartCard(
        title: 'Voltage timeline',
        child: SizedBox(
          height: 180,
          child: Center(
            child: Text(
              'Could not load samples: $e',
              style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
            ),
          ),
        ),
      ),
      data: (samples) =>
          samples.isEmpty ? _empty() : _buildChart(samples, model),
    );
  }

  Widget _empty() => _ChartCard(
        title: 'Voltage timeline',
        child: SizedBox(
          height: 180,
          child: Center(
            child: Text(
              'No samples in sensorHistory yet — seed first.',
              style: AppTypography.bodySmall,
            ),
          ),
        ),
      );

  Widget _buildChart(List<SensorReading> samples, BaselineModel? model) {
    final downsampled = _downsample(samples, 600);
    final spots = <FlSpot>[
      for (var i = 0; i < downsampled.length; i++)
        FlSpot(i.toDouble(), downsampled[i].voltage),
    ];

    final values = downsampled.map((r) => r.voltage).toList();
    final minY = (values.reduce(math.min) - 2);
    final maxY = (values.reduce(math.max) + 2);
    final hi = model == null ? null : model.voltageMean + 3 * model.voltageStd;
    final lo = model == null ? null : model.voltageMean - 3 * model.voltageStd;

    return _ChartCard(
      title: 'Voltage envelope (μ ± 3σ)',
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                if (model != null)
                  HorizontalLine(
                    y: model.voltageP01,
                    color: AppColors.danger.withValues(alpha: 0.6),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                if (model != null)
                  HorizontalLine(
                    y: model.voltageP99,
                    color: AppColors.danger.withValues(alpha: 0.6),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                if (model != null)
                  HorizontalLine(
                    y: model.voltageMean,
                    color: AppColors.primary.withValues(alpha: 0.4),
                    strokeWidth: 1,
                  ),
              ],
            ),
            lineBarsData: [
              if (hi != null && lo != null)
                LineChartBarData(
                  spots: [
                    FlSpot(0, hi),
                    FlSpot((spots.length - 1).toDouble(), hi),
                  ],
                  isCurved: false,
                  color: AppColors.success.withValues(alpha: 0.3),
                  barWidth: 0,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.success.withValues(alpha: 0.10),
                    cutOffY: lo,
                    applyCutOffY: true,
                  ),
                ),
              LineChartBarData(
                spots: spots,
                isCurved: false,
                color: AppColors.primary,
                barWidth: 1.4,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<SensorReading> _downsample(List<SensorReading> src, int target) {
    if (src.length <= target) return src;
    final step = src.length / target;
    return [for (var i = 0; i < target; i++) src[(i * step).floor()]];
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.model});
  final BaselineModel? model;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final entries = <(String, String)>[
      ('μ_V', m == null ? '—' : '${m.voltageMean.toStringAsFixed(2)} V'),
      ('σ_V', m == null ? '—' : '${m.voltageStd.toStringAsFixed(3)} V'),
      ('P01_V', m == null ? '—' : '${m.voltageP01.toStringAsFixed(1)} V'),
      ('P99_V', m == null ? '—' : '${m.voltageP99.toStringAsFixed(1)} V'),
      ('μ_I', m == null ? '—' : '${m.currentMean.toStringAsFixed(3)} A'),
      ('σ_I', m == null ? '—' : '${m.currentStd.toStringAsFixed(3)} A'),
      (
        'max ΔV/s',
        m == null ? '—' : '${m.voltageMaxRate.toStringAsFixed(2)} V/s',
      ),
      ('Samples', m == null ? '—' : '${m.sampleCount}'),
      ('Train ms', m == null ? '—' : '${m.trainingDurationMs}'),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Learnt parameters', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0,
            ),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final (label, value) = entries[i];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: AppTypography.bodySmall),
                    Text(
                      value,
                      style: AppTypography.mono.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MahalanobisChart extends ConsumerWidget {
  const _MahalanobisChart({required this.state});
  final TrainingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = state.model;
    if (m == null) {
      return _ChartCard(
        title: 'Joint V/I distribution',
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Train to see Mahalanobis ellipse.',
              style: AppTypography.bodySmall,
            ),
          ),
        ),
      );
    }

    final samplesAsync = ref.watch(cachedTrainingSamplesProvider);
    return samplesAsync.when(
      loading: () => _ChartCard(
        title: 'Joint V/I distribution',
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text('Loading samples…', style: AppTypography.bodySmall),
          ),
        ),
      ),
      error: (e, _) => _ChartCard(
        title: 'Joint V/I distribution',
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Could not load samples: $e',
              style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
            ),
          ),
        ),
      ),
      data: (samples) =>
          samples.isEmpty ? _empty() : _buildChart(samples, m),
    );
  }

  Widget _empty() => _ChartCard(
        title: 'Joint V/I distribution',
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'No samples in sensorHistory yet.',
              style: AppTypography.bodySmall,
            ),
          ),
        ),
      );

  Widget _buildChart(List<SensorReading> samples, BaselineModel m) {
    final pts = _downsample(samples, 400);
    final scatter = <ScatterSpot>[
      for (final r in pts)
        ScatterSpot(
          r.voltage,
          r.current,
          dotPainter: FlDotCirclePainter(
            color: AppColors.primary.withValues(alpha: 0.55),
            radius: 1.6,
          ),
        ),
    ];

    final ellipse = _ellipseSpots(m);
    final xs = pts.map((r) => r.voltage).toList()..sort();
    final ys = pts.map((r) => r.current).toList()..sort();
    final minX = (xs.first - 1.0);
    final maxX = (xs.last + 1.0);
    final minY = math.max(0.0, ys.first - 0.05);
    final maxY = ys.last + 0.1;

    return _ChartCard(
      title: 'Joint V/I distribution + 99% confidence ellipse',
      child: SizedBox(
        height: 220,
        child: ScatterChart(
          ScatterChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (v, _) => Text(
                    v.toStringAsFixed(1),
                    style: AppTypography.monoSmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (v, _) => Text(
                    v.toStringAsFixed(0),
                    style: AppTypography.monoSmall,
                  ),
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            scatterSpots: [
              ...scatter,
              for (final p in ellipse)
                ScatterSpot(
                  p.$1,
                  p.$2,
                  dotPainter: FlDotCirclePainter(
                    color: AppColors.danger,
                    radius: 1.4,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static List<SensorReading> _downsample(List<SensorReading> src, int target) {
    if (src.length <= target) return src;
    final step = src.length / target;
    return [for (var i = 0; i < target; i++) src[(i * step).floor()]];
  }

  static List<(double, double)> _ellipseSpots(BaselineModel m) {
    final tr = m.covVV + m.covII;
    final det = m.covVV * m.covII - m.covVI * m.covVI;
    final disc = math.max(0.0, (tr / 2) * (tr / 2) - det);
    final l1 = tr / 2 + math.sqrt(disc);
    final l2 = tr / 2 - math.sqrt(disc);
    final theta = 0.5 * math.atan2(2 * m.covVI, m.covVV - m.covII);
    final cs = math.cos(theta);
    final sn = math.sin(theta);
    final r1 = math.sqrt(m.mahalanobisChi2Threshold * math.max(l1, 0));
    final r2 = math.sqrt(m.mahalanobisChi2Threshold * math.max(l2, 0));

    final out = <(double, double)>[];
    const steps = 60;
    for (var i = 0; i <= steps; i++) {
      final t = (2 * math.pi * i) / steps;
      final x = r1 * math.cos(t);
      final y = r2 * math.sin(t);
      final xr = m.voltageMean + cs * x - sn * y;
      final yr = m.currentMean + sn * x + cs * y;
      out.add((xr, yr));
    }
    return out;
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({required this.state, required this.vm});
  final TrainingState state;
  final BaselineTrainingViewModel vm;

  @override
  Widget build(BuildContext context) {
    final busy =
        state.phase == TrainingPhase.seeding ||
        state.phase == TrainingPhase.loading ||
        state.phase == TrainingPhase.fitting;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: busy ? null : () => vm.trainFromRtdb(),
            icon: const Icon(Icons.auto_graph_rounded),
            label: const Text('Train baseline'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: state.model == null
                ? null
                : () async {
                    await vm.activate();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Baseline activated — live monitoring on.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save & activate monitoring'),
          ),
        ),
      ],
    );
  }
}
