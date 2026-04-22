import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/appliance.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/iot_monitor/view_models/alerts_view_model.dart';
import 'package:skilllink/skillink/ui/iot_monitor/view_models/appliances_list_view_model.dart';
import 'package:skilllink/skillink/ui/iot_monitor/widgets/add_appliance_sheet.dart';
import 'package:skilllink/skillink/ui/iot_monitor/widgets/anomaly_visuals.dart';

class AppliancesListScreen extends ConsumerWidget {
  const AppliancesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AppliancesListState>(
      appliancesListViewModelProvider,
      (prev, next) {
        final msg = next.errorMessage;
        if (msg == null || msg == prev?.errorMessage) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
          ));
        ref.read(appliancesListViewModelProvider.notifier).clearError();
      },
    );

    final state = ref.watch(appliancesListViewModelProvider);
    final alerts = ref.watch(alertsViewModelProvider);
    final unread = alerts.unreadCount;
    final openAnomalyApplianceIds = <String>{
      for (final a in alerts.anomalies)
        if (!a.read) a.applianceId,
    };
    final vm = ref.read(appliancesListViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Live Monitor', style: AppTypography.headlineMedium),
        actions: [
          _AlertsBellAction(unread: unread),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Appliance'),
        backgroundColor: AppColors.primary,
      ),
      body: RefreshIndicator(
        onRefresh: vm.refresh,
        child: state.isLoading && state.appliances.isEmpty
            ? const _GridShimmer()
            : state.appliances.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.6,
                        child: EmptyState(
                          icon: Icons.electrical_services_rounded,
                          title: 'No appliances yet',
                          subtitle:
                              'Pair your ESP32 smart plug and track voltage, '
                              'current, and wattage in real time.',
                          actionLabel: 'Add Appliance',
                          onAction: () => _showAddSheet(context, ref),
                        ),
                      ),
                    ],
                  )
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: state.appliances.length,
                    itemBuilder: (_, i) {
                      final appliance = state.appliances[i];
                      final device = appliance.iotDeviceId;
                      final live = device == null
                          ? null
                          : state.liveByDeviceId[device];
                      return _ApplianceTile(
                        appliance: appliance,
                        liveReading: live,
                        hasOpenAnomaly:
                            openAnomalyApplianceIds.contains(appliance.id),
                        onTap: () => context.push(
                          Routes.applianceDetail(appliance.id),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddApplianceSheet(),
    );
  }
}

class _AlertsBellAction extends StatelessWidget {
  const _AlertsBellAction({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => context.push(Routes.alerts),
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textPrimary),
          tooltip: 'Alerts',
        ),
        if (unread > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                textAlign: TextAlign.center,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ApplianceTile extends StatelessWidget {
  const _ApplianceTile({
    required this.appliance,
    required this.liveReading,
    required this.hasOpenAnomaly,
    required this.onTap,
  });

  final Appliance appliance;
  final SensorReading? liveReading;
  final bool hasOpenAnomaly;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dotColor = AnomalyVisuals.statusDotFor(
      hasLive: liveReading != null,
      hasOpenAnomaly: hasOpenAnomaly,
    );

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                offset: const Offset(0, 4),
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AnomalyVisuals.iconForApplianceType(appliance.type),
                        color: AppColors.accent,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: dotColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  appliance.brand,
                  style: AppTypography.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  appliance.model,
                  style: AppTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  liveReading == null
                      ? '— W'
                      : '${liveReading!.wattage.toStringAsFixed(0)} W',
                  style: AppTypography.mono.copyWith(
                    color: AppColors.accent,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  liveReading == null ? 'Waiting for data…' : 'Live',
                  style: AppTypography.monoSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: List.generate(4, (_) => const LoadingShimmer(height: 180)),
    );
  }
}
