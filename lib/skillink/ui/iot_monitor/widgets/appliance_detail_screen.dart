import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/repositories/iot_repository.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/domain/models/appliance.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/sensor_gauge.dart';
import 'package:skilllink/skillink/ui/iot_monitor/view_models/appliance_detail_view_model.dart';
import 'package:skilllink/skillink/ui/iot_monitor/widgets/anomaly_visuals.dart';

class ApplianceDetailScreen extends ConsumerWidget {
  const ApplianceDetailScreen({super.key, required this.applianceId});

  final String applianceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = applianceDetailViewModelProvider(applianceId);

    ref.listen<ApplianceDetailState>(provider, (prev, next) {
      final msg = next.errorMessage;
      if (msg == null || msg == prev?.errorMessage) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
        ));
      ref.read(provider.notifier).clearError();
    });

    final state = ref.watch(provider);
    final vm = ref.read(provider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          state.appliance == null
              ? 'Appliance'
              : '${state.appliance!.brand} ${_typeLabel(state.appliance!.type)}',
          style: AppTypography.headlineMedium,
        ),
      ),
      body: _body(context, state, vm),
    );
  }

  Widget _body(
    BuildContext context,
    ApplianceDetailState state,
    ApplianceDetailViewModel vm,
  ) {
    if (state.isLoading && state.appliance == null) {
      return const _Shimmer();
    }
    if (state.appliance == null) {
      return ErrorView(
        message: state.errorMessage ?? 'Appliance not found.',
        onRetry: vm.retry,
      );
    }

    final appliance = state.appliance!;
    final live = state.latestReading;
    final anomalyOpen = state.anomalies.any((a) => !a.read);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _StatusBadge(open: anomalyOpen, deviceId: appliance.iotDeviceId),
        const SizedBox(height: 16),
        _GaugesRow(reading: live, appliance: appliance),
        const SizedBox(height: 20),
        _HistoryCard(state: state, vm: vm),
        const SizedBox(height: 16),
        _StatsCard(state: state),
        const SizedBox(height: 16),
        _AnomalyHistoryCard(anomalies: state.anomalies),
        if (AppConstants.showSimulateAnomalyButton) ...[
          const SizedBox(height: 20),
          _SimulateAnomalyButton(
            disabled: state.isSimulating,
            onPressed: () async {
              final id = await vm.simulateAnomaly();
              if (id == null || !context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: const Text(
                    'Health alert sent — check your notification tray to book '
                    'a technician.',
                  ),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Open',
                    onPressed: () => context.push(Routes.alertDetail(id)),
                  ),
                ));
            },
          ),
        ],
      ],
    );
  }

  static String _typeLabel(String type) => switch (type.toLowerCase()) {
        'ac' || 'hvac' => 'AC',
        'fridge' => 'Fridge',
        'heater' => 'Heater',
        'washer' => 'Washer',
        'oven' => 'Oven',
        'tv' => 'TV',
        _ => type,
      };
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.open, required this.deviceId});

  final bool open;
  final String? deviceId;

  @override
  Widget build(BuildContext context) {
    final color = open ? AppColors.danger : AppColors.success;
    final label = open ? 'Attention needed' : 'All good';
    final sub = deviceId == null || deviceId!.isEmpty
        ? 'No device paired'
        : 'Device: $deviceId';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.labelLarge.copyWith(color: color)),
                Text(sub, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugesRow extends StatelessWidget {
  const _GaugesRow({required this.reading, required this.appliance});

  final SensorReading? reading;
  final Appliance appliance;

  @override
  Widget build(BuildContext context) {
    // ListView children get unbounded max height; do not use stretch here.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SensorGauge(
            label: 'Voltage',
            value: reading?.voltage ?? 0,
            unit: 'V',
            minValue: 180,
            maxValue: 260,
            isAnomalous: (reading?.voltage ?? 0) > 240,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SensorGauge(
            label: 'Current',
            value: reading?.current ?? 0,
            unit: 'A',
            maxValue: 10,
            isAnomalous: (reading?.current ?? 0) > 8,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SensorGauge(
            label: 'Wattage',
            value: reading?.wattage ?? 0,
            unit: 'W',
            maxValue: 2000,
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.state, required this.vm});

  final ApplianceDetailState state;
  final ApplianceDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Power over time',
                      style: AppTypography.titleLarge)),
              _WindowPicker(
                value: state.historyWindow,
                onChanged: vm.setHistoryWindow,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: state.history.isEmpty
                ? Center(
                    child: Text(
                      'Not enough data yet.',
                      style: AppTypography.bodySmall,
                    ),
                  )
                : _WattageChart(history: state.history),
          ),
        ],
      ),
    );
  }
}

class _WindowPicker extends StatelessWidget {
  const _WindowPicker({required this.value, required this.onChanged});

  final SensorHistoryWindow value;
  final ValueChanged<SensorHistoryWindow> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SensorHistoryWindow>(
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll(AppTypography.labelMedium),
      ),
      segments: const [
        ButtonSegment(
          value: SensorHistoryWindow.hour,
          label: Text('1h'),
        ),
        ButtonSegment(
          value: SensorHistoryWindow.day,
          label: Text('24h'),
        ),
        ButtonSegment(
          value: SensorHistoryWindow.week,
          label: Text('7d'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _WattageChart extends StatelessWidget {
  const _WattageChart({required this.history});

  final List<SensorReading> history;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < history.length; i++)
        FlSpot(i.toDouble(), history[i].wattage),
    ];
    final rawMax = history
            .map((r) => r.wattage)
            .fold<double>(0, (m, w) => w > m ? w : m) *
        1.15;
    final maxY = rawMax.isFinite && rawMax > 0 ? rawMax : 1.0;
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 4).clamp(1, double.infinity),
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.accent,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accent.withValues(alpha: 0.25),
                  AppColors.accent.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.state});

  final ApplianceDetailState state;

  @override
  Widget build(BuildContext context) {
    final avg = state.averageWattage;
    final peak = state.peakWattage;
    final cost = state.estimatedDailyCostPkr();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatTile(
              label: 'Avg power',
              value: avg == null ? '—' : '${avg.toStringAsFixed(0)} W'),
          _divider(),
          _StatTile(
              label: 'Peak',
              value: peak == null ? '—' : '${peak.toStringAsFixed(0)} W'),
          _divider(),
          _StatTile(
            label: 'Est. daily',
            value: cost == null ? '—' : 'Rs ${cost.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 40,
        color: AppColors.divider,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.mono.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnomalyHistoryCard extends StatelessWidget {
  const _AnomalyHistoryCard({required this.anomalies});

  final List<Anomaly> anomalies;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Anomaly history', style: AppTypography.titleLarge),
          const SizedBox(height: 10),
          if (anomalies.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'No anomalies detected for this appliance.',
                style: AppTypography.bodySmall,
              ),
            )
          else
            for (final a in anomalies)
              _AnomalyRow(anomaly: a),
        ],
      ),
    );
  }
}

class _AnomalyRow extends StatelessWidget {
  const _AnomalyRow({required this.anomaly});

  final Anomaly anomaly;

  @override
  Widget build(BuildContext context) {
    final color = AnomalyVisuals.colorForSeverity(anomaly.severity);
    return InkWell(
      onTap: () => context.push(Routes.alertDetail(anomaly.id)),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                AnomalyVisuals.iconForType(anomaly.type),
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AnomalyVisuals.titleForType(anomaly.type),
                      style: AppTypography.labelLarge),
                  Text(
                    '${AnomalyVisuals.severityLabel(anomaly.severity)} · '
                    '${AnomalyVisuals.timeAgo(anomaly.detectedAt)}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SimulateAnomalyButton extends StatelessWidget {
  const _SimulateAnomalyButton({
    required this.disabled,
    required this.onPressed,
  });

  final bool disabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: disabled ? null : onPressed,
        icon: disabled
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.warning_amber_rounded),
        label: Text(
          disabled ? 'Creating alert…' : 'Simulate health alert',
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: const [
        LoadingShimmer(height: 56),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: LoadingShimmer(height: 130)),
            SizedBox(width: 10),
            Expanded(child: LoadingShimmer(height: 130)),
            SizedBox(width: 10),
            Expanded(child: LoadingShimmer(height: 130)),
          ],
        ),
        SizedBox(height: 20),
        LoadingShimmer(height: 220),
        SizedBox(height: 16),
        LoadingShimmer(height: 80),
      ],
    );
  }
}
