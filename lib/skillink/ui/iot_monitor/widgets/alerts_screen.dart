import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/iot_monitor/view_models/alerts_view_model.dart';
import 'package:skilllink/skillink/ui/iot_monitor/widgets/anomaly_visuals.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AlertsState>(alertsViewModelProvider, (prev, next) {
      final msg = next.errorMessage;
      if (msg == null || msg == prev?.errorMessage) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
        ));
      ref.read(alertsViewModelProvider.notifier).clearError();
    });

    final state = ref.watch(alertsViewModelProvider);
    final vm = ref.read(alertsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Alerts', style: AppTypography.headlineMedium),
      ),
      body: RefreshIndicator(
        onRefresh: vm.refresh,
        child: state.isLoading && state.anomalies.isEmpty
            ? const LoadingShimmerList(itemCount: 4)
            : state.anomalies.isEmpty
                ? LayoutBuilder(
                    builder: (_, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: const EmptyState(
                          icon: Icons.notifications_none_rounded,
                          title: 'All clear',
                          subtitle:
                              'No anomalies detected. We will alert you the '
                              'moment your smart plug notices anything off.',
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: state.anomalies.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final a = state.anomalies[i];
                      return _AlertTile(
                        anomaly: a,
                        onTap: () {
                          if (!a.read) vm.markRead(a.id);
                          context.push(Routes.alertDetail(a.id));
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.anomaly, required this.onTap});

  final Anomaly anomaly;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AnomalyVisuals.colorForSeverity(anomaly.severity);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: anomaly.read
                  ? AppColors.border
                  : color.withValues(alpha: 0.4),
            ),
            boxShadow: anomaly.read
                ? null
                : [
                    BoxShadow(
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                      color: color.withValues(alpha: 0.12),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AnomalyVisuals.iconForType(anomaly.type),
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AnomalyVisuals.titleForType(anomaly.type),
                              style: AppTypography.titleLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              AnomalyVisuals.severityLabel(anomaly.severity),
                              style: AppTypography.labelMedium.copyWith(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        anomaly.applianceName ?? 'Appliance',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AnomalyVisuals.timeAgo(anomaly.detectedAt),
                        style: AppTypography.monoSmall,
                      ),
                    ],
                  ),
                ),
                if (!anomaly.read) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
