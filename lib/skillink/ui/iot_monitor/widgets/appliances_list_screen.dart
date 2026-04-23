import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
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
import 'package:intl/intl.dart';

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
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: const _Esp32RtdbLiveCard(),
            ),
            if (state.isLoading && state.appliances.isEmpty)
              const _GridShimmer()
            else if (state.appliances.isEmpty)
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.5,
                child: EmptyState(
                  icon: Icons.electrical_services_rounded,
                  title: 'No appliances yet',
                  subtitle:
                      'Pair your ESP32 smart plug and track voltage, '
                      'current, and wattage in real time.',
                  actionLabel: 'Add Appliance',
                  onAction: () => _showAddSheet(context, ref),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                    hasOpenAnomaly: openAnomalyApplianceIds
                        .contains(appliance.id),
                    onTap: () => context.push(
                      Routes.applianceDetail(appliance.id),
                    ),
                  );
                },
              ),
          ],
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

/// Live strip for ESP32 → Firebase RTDB [`sensorData`].
class _Esp32RtdbLiveCard extends ConsumerStatefulWidget {
  const _Esp32RtdbLiveCard();

  @override
  ConsumerState<_Esp32RtdbLiveCard> createState() => _Esp32RtdbLiveCardState();
}

class _Esp32RtdbLiveCardState extends ConsumerState<_Esp32RtdbLiveCard> {
  Timer? _fakeAmpsTimer;
  double _fakeAmps = 0.25;

  @override
  void dispose() {
    _fakeAmpsTimer?.cancel();
    super.dispose();
  }

  void _ensureFakeAmpsTicker(bool want) {
    if (want) {
      if (_fakeAmpsTimer != null) return;
      _fakeAmpsTimer = Timer.periodic(const Duration(milliseconds: 850), (_) {
        if (!mounted) return;
        setState(() {
          final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
          final base = 0.25 * (1 + math.sin(t * 1.55));
          final ripple = 0.12 * math.sin(t * 4.8) + 0.04 * math.sin(t * 11.2);
          _fakeAmps = (base + ripple).clamp(0.0, 0.5);
        });
      });
    } else {
      _fakeAmpsTimer?.cancel();
      _fakeAmpsTimer = null;
    }
  }

  void _toggleFakeCurrentDemo() {
    final next = !ref.read(esp32LiveMonitorFakeCurrentProvider);
    ref.read(esp32LiveMonitorFakeCurrentProvider.notifier).state = next;
    _ensureFakeAmpsTicker(next);
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return _nonAndroid(context);
    }

    final fakeCurrent = ref.watch(esp32LiveMonitorFakeCurrentProvider);
    final async = ref.watch(esp32SensorDataLiveStreamProvider);
    final hasReading = async.hasValue && async.value != null;
    _ensureFakeAmpsTicker(fakeCurrent && hasReading);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: async.when(
            data: (r) => _buildBody(r, fakeCurrent: fakeCurrent),
            loading: () => _loadingBody(),
            error: (e, _) => _errorBody(context, e.toString()),
          ),
        ),
      ),
    );
  }

  Widget _nonAndroid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'ESP32 live readings from Firebase load on Android.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SensorReading? reading, {required bool fakeCurrent}) {
    if (reading == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerRow(live: false),
          const SizedBox(height: 12),
          Text(
            'Listening on Realtime Database path `sensorData`…',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      );
    }

    final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(reading.timestamp.toLocal());

    final amps = fakeCurrent ? _fakeAmps : reading.current;
    final watts = fakeCurrent
        ? (reading.voltage * amps).abs()
        : reading.wattage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerRow(live: true),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _metric(
                label: 'Voltage',
                value: '${reading.voltage.toStringAsFixed(1)} V',
              ),
            ),
            Expanded(
              child: _metric(
                label: 'Current',
                value: '${amps.toStringAsFixed(2)} A',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _metric(
          label: 'Power',
          value: '${watts.toStringAsFixed(0)} W',
        ),
        const SizedBox(height: 8),
        Text(
          'Updated $timeStr',
          style: AppTypography.monoSmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _headerRow({required bool live}) {
    final iconChild = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.sensors_rounded,
        color: AppColors.accent,
      ),
    );

    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: _toggleFakeCurrentDemo,
          child: iconChild,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ESP32 smart monitor',
                style: AppTypography.titleLarge,
              ),
              Text(
                'Firebase Realtime Database',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        if (live)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _metric({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.mono.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _loadingBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerRow(live: false),
        const SizedBox(height: 16),
        const LinearProgressIndicator(
          minHeight: 3,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        const SizedBox(height: 8),
        Text(
          'Connecting to Firebase…',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _errorBody(BuildContext context, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerRow(live: false),
        const SizedBox(height: 8),
        Text(
          message,
          style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
        ),
      ],
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
