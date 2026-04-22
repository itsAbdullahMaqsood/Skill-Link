import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/secondary_button.dart';
import 'package:skilllink/skillink/ui/iot_monitor/view_models/alerts_view_model.dart';
import 'package:skilllink/skillink/ui/iot_monitor/widgets/anomaly_visuals.dart';
import 'package:skilllink/skillink/utils/result.dart';

class AlertDetailScreen extends ConsumerStatefulWidget {
  const AlertDetailScreen({super.key, required this.anomalyId});

  final String anomalyId;

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  late Future<Result<Anomaly>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Result<Anomaly>> _load() {
    return ref.read(iotRepositoryProvider).getAnomaly(widget.anomalyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Alert Detail', style: AppTypography.headlineMedium),
      ),
      body: FutureBuilder<Result<Anomaly>>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingShimmer(height: 220),
            );
          }
          return snap.data!.when(
            success: (a) => _body(a),
            failure: (msg, _) => ErrorView(
              message: msg,
              onRetry: () => setState(() => _future = _load()),
            ),
          );
        },
      ),
    );
  }

  Widget _body(Anomaly a) {
    final color = AnomalyVisuals.colorForSeverity(a.severity);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(AnomalyVisuals.iconForType(a.type),
                    color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AnomalyVisuals.titleForType(a.type),
                        style: AppTypography.headlineSmall
                            .copyWith(color: color)),
                    const SizedBox(height: 2),
                    Text(
                      '${AnomalyVisuals.severityLabel(a.severity)} severity · '
                      '${AnomalyVisuals.timeAgo(a.detectedAt)}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (a.applianceName != null) ...[
          _InfoRow(
            icon: Icons.electrical_services_rounded,
            label: 'Appliance',
            value: a.applianceName!,
          ),
          const SizedBox(height: 8),
        ],
        _InfoRow(
          icon: Icons.schedule_rounded,
          label: 'Detected',
          value: _formatTimestamp(a.detectedAt),
        ),
        if (a.message != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
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
                Text('What happened', style: AppTypography.titleLarge),
                const SizedBox(height: 6),
                Text(a.message!, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (a.suggestedTrade != null) ...[
          PrimaryButton(
            label: 'Book Technician',
            icon: Icons.handyman_rounded,
            onPressed: () {
              context.go(Routes.marketplace(trade: a.suggestedTrade));
            },
          ),
          const SizedBox(height: 10),
        ],
        SecondaryButton(
          label: a.read ? 'Marked as read' : 'Mark as read',
          onPressed: a.read
              ? null
              : () async {
                  await ref
                      .read(alertsViewModelProvider.notifier)
                      .markRead(a.id);
                  if (!mounted) return;
                  setState(() => _future = _load());
                },
        ),
      ],
    );
  }

  static String _formatTimestamp(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(label, style: AppTypography.bodySmall),
        ),
        Expanded(
          child: Text(value, style: AppTypography.labelLarge),
        ),
      ],
    );
  }
}
