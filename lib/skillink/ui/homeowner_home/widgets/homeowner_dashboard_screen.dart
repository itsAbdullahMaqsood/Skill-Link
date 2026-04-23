import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/appliance.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/job_status_chip.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/worker_card.dart';
import 'package:skilllink/skillink/ui/service_requests/widgets/sent_requests_screen.dart';
import 'package:skilllink/skillink/ui/homeowner_home/view_models/homeowner_dashboard_view_model.dart';
import 'package:skilllink/skillink/ui/iot_monitor/view_models/appliances_list_view_model.dart';
import 'package:skilllink/skillink/ui/job_tracking/view_models/rated_jobs_provider.dart';
import 'package:skilllink/skillink/ui/iot_monitor/widgets/anomaly_visuals.dart';
import 'package:skilllink/skillink/ui/marketplace/view_models/marketplace_view_model.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/open_job_post_card.dart';
import 'package:skilllink/skillink/utils/text_format.dart';
import 'package:skilllink/skillink/utils/trade_icon.dart';

class HomeownerDashboardScreen extends ConsumerWidget {
  const HomeownerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<HomeownerDashboardState>(homeownerDashboardViewModelProvider, (
      prev,
      next,
    ) {
      final msg = next.errorMessage;
      if (msg == null || msg == prev?.errorMessage) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      ref.read(homeownerDashboardViewModelProvider.notifier).clearError();
    });

    final state = ref.watch(homeownerDashboardViewModelProvider);
    final user = ref.watch(authViewModelProvider).user;
    final viewModel = ref.read(homeownerDashboardViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu_rounded),
        ),
        title: Text('SkillLink', style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push(Routes.notifications),
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            myServiceRequestsProvider(ServiceRequestRole.customer),
          );
          ref.invalidate(myOpenJobPostsProvider(ServiceRequestRole.customer));
          await viewModel.refresh();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _GreetingCard(name: user?.name),
            const SizedBox(height: 20),

            const _QuickBookRow(),
            const SizedBox(height: 24),

            if (state.isLoading && state.activeJob == null) ...[
              const LoadingShimmer(height: 120),
              const SizedBox(height: 16),
              const LoadingShimmer(height: 64),
              const SizedBox(height: 24),
              const LoadingShimmer(height: 88),
              const SizedBox(height: 8),
              const LoadingShimmer(height: 88),
            ] else ...[
              const _UnratedBanner(),

              if (state.activeJob != null) ...[
                const _SectionHeader(title: 'In Progress Job'),
                const SizedBox(height: 8),
                _ActiveJobCard(job: state.activeJob!),
                const SizedBox(height: 20),
              ],

              const _ActiveServicesSection(),

              const _RequestedServicesSection(),
              const SizedBox(height: 20),

              const _IoTDevicesHealthSection(),
              const SizedBox(height: 20),

              const _MyOpenPostsSection(),
              const SizedBox(height: 20),

              const _MarketplacePreviewSection(),
            ],
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    final trimmed = (name ?? '').trim();
    final firstName = trimmed.isEmpty
        ? 'there'
        : trimmed.split(RegExp(r'\s+')).first;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 8),
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  firstName,
                  style: AppTypography.headlineLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Need help at home? Book a verified pro in minutes.',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.handyman_outlined, color: Colors.white, size: 44),
        ],
      ),
    );
  }
}

class _QuickBookRow extends StatelessWidget {
  const _QuickBookRow();

  static const List<({String trade, String label})> _shortcuts = [
    (trade: 'electrician', label: 'Electrician'),
    (trade: 'plumber', label: 'Plumber'),
    (trade: 'hvac', label: 'AC / HVAC'),
    (trade: 'carpenter', label: 'Carpenter'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Book', style: AppTypography.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < _shortcuts.length; i++) ...[
              Expanded(
                child: _QuickBookTile(
                  label: _shortcuts[i].label,
                  icon: TradeIcon.forTrade(_shortcuts[i].trade),
                  onTap: () {
                    context.go(Routes.marketplace(trade: _shortcuts[i].trade));
                  },
                ),
              ),
              if (i != _shortcuts.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _QuickBookTile extends StatelessWidget {
  const _QuickBookTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: const Offset(0, 4),
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.titleLarge),
        ?trailing,
      ],
    );
  }
}

class _UnratedBanner extends ConsumerWidget {
  const _UnratedBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(mostRecentUnratedJobProvider);
    if (job == null) return const SizedBox.shrink();

    final tradeLabel = TextFormat.trade(job.serviceType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push(Routes.rateJob(job.jobId)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.18),
                  child: const Icon(
                    Icons.star_rounded,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate your last service',
                        style: AppTypography.titleLarge.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$tradeLabel · tap to leave a review',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Dismiss',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.textMuted,
                  onPressed: () => ref
                      .read(ratedJobsTrackerProvider.notifier)
                      .dismiss(job.jobId),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  const _ActiveJobCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(Routes.jobTracking(job.jobId)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        TradeIcon.forTrade(job.serviceType),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TextFormat.trade(job.serviceType),
                            style: AppTypography.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.description,
                            style: AppTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    JobStatusChip(status: job.status.name),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (job.finalPrice != null) ...[
                      const Icon(
                        Icons.payments_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Rs ${job.finalPrice!.toStringAsFixed(0)}',
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(width: 16),
                    ],
                    const Icon(
                      Icons.event_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatSchedule(job.scheduledDate),
                      style: AppTypography.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatSchedule(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    if (isToday) return 'Today, $hh:$mm';
    return '${dt.day}/${dt.month}, $hh:$mm';
  }
}

class _IoTDevicesHealthSection extends ConsumerWidget {
  const _IoTDevicesHealthSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iotState = ref.watch(appliancesListViewModelProvider);
    final appliances = iotState.appliances;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'IoT Devices Health',
          trailing: appliances.isNotEmpty
              ? TextButton(
                  onPressed: () => context.push(Routes.iotDevices),
                  child: const Text('See all'),
                )
              : null,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: appliances.isEmpty
              ? ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _AddDeviceCard(
                      onTap: () => context.push(Routes.iotDevices),
                    ),
                  ],
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: appliances.length.clamp(0, 5),
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final a = appliances[i];
                    final live = iotState.liveByDeviceId[a.iotDeviceId];
                    return _DeviceHealthCard(appliance: a, live: live);
                  },
                ),
        ),
        const SizedBox(height: 12),
        const _TestHealthAnomalyCta(),
      ],
    );
  }
}

/// Demo: creates an anomaly via API/fake IoT repo and raises a local notification
/// that prompts the user to book a technician.
class _TestHealthAnomalyCta extends ConsumerStatefulWidget {
  const _TestHealthAnomalyCta();

  @override
  ConsumerState<_TestHealthAnomalyCta> createState() =>
      _TestHealthAnomalyCtaState();
}

class _TestHealthAnomalyCtaState extends ConsumerState<_TestHealthAnomalyCta> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final appliances = ref.watch(appliancesListViewModelProvider).appliances;
    if (appliances.isEmpty) {
      return Text(
        'Pair an appliance under IoT to test health alerts and technician '
        'booking.',
        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _trigger(String applianceId) async {
    setState(() => _busy = true);
    final res = await ref
        .read(iotRepositoryProvider)
        .simulateAnomaly(applianceId: applianceId, type: 'voltage_spike');
    if (!mounted) return;
    setState(() => _busy = false);

    res.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Check your notifications: device health warning with a prompt '
              'to book a technician.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      failure: (msg, _) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }
}

class _DeviceHealthCard extends StatelessWidget {
  const _DeviceHealthCard({required this.appliance, this.live});

  final Appliance appliance;
  final SensorReading? live;

  @override
  Widget build(BuildContext context) {
    final hasData = live != null;
    return GestureDetector(
      onTap: () => context.push(Routes.applianceDetail(appliance.id)),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 2),
              color: Colors.black.withValues(alpha: 0.04),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AnomalyVisuals.iconForApplianceType(appliance.type),
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    appliance.brand,
                    style: AppTypography.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasData ? AppColors.success : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  hasData ? '${live!.wattage.toStringAsFixed(0)} W' : 'Offline',
                  style: AppTypography.labelMedium.copyWith(
                    fontFamily: 'JetBrains Mono',
                    color: hasData
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddDeviceCard extends StatelessWidget {
  const _AddDeviceCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              'Add Device',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _kInlineOpenPostsCap = 5;

class _MyOpenPostsSection extends ConsumerWidget {
  const _MyOpenPostsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      myOpenJobPostsProvider(ServiceRequestRole.customer),
    );
    return async.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader(title: 'Posted Jobs'),
          SizedBox(height: 8),
          LoadingShimmerList(),
        ],
      ),
      error: (e, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Posted Jobs'),
          const SizedBox(height: 8),
          Text(
            '$e',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Posted Jobs'),
              SizedBox(height: 8),
              EmptyState(
                icon: Icons.post_add_outlined,
                title: 'No posted jobs yet',
                subtitle: 'Tap the + button to post your first job.',
              ),
            ],
          );
        }
        final visible = posts.take(_kInlineOpenPostsCap).toList();
        final hiddenCount = posts.length - visible.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Posted Jobs',
              trailing: TextButton(
                onPressed: () => context.push(Routes.myPosts),
                child: const Text('See all'),
              ),
            ),
            const SizedBox(height: 8),
            for (final p in visible)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OpenJobPostCard(
                  post: p,
                  onTap: () => context.push(Routes.openJobPostDetail(p.id)),
                  trailing:
                      (p.bidCount != null &&
                          p.status == OpenJobPostStatus.openForBids)
                      ? _BidCountBadge(count: p.bidCount!)
                      : null,
                ),
              ),
            if (hiddenCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Text(
                  'Showing $_kInlineOpenPostsCap of ${posts.length} posts.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BidCountBadge extends StatelessWidget {
  const _BidCountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count bid${count == 1 ? '' : 's'}',
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.primary,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MarketplacePreviewSection extends ConsumerWidget {
  const _MarketplacePreviewSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mpState = ref.watch(marketplaceViewModelProvider(null));
    final serviceMap =
        ref.watch(labourServiceIdToNameProvider).valueOrNull ?? const {};

    final workers = mpState.workers.when(
      data: (list) => list.take(5).toList(),
      loading: () => <Worker>[],
      error: (_, _) => <Worker>[],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Marketplace',
          trailing: workers.isNotEmpty
              ? TextButton(
                  onPressed: () => context.go(Routes.homeownerMarketplace),
                  child: const Text('See all'),
                )
              : null,
        ),
        const SizedBox(height: 8),
        if (workers.isEmpty && mpState.workers.isLoading)
          const SizedBox(
            height: AppConstants.homeMarketplacePreviewStripHeight,
            child: Center(child: LoadingShimmer(height: 80)),
          )
        else if (workers.isEmpty)
          const EmptyState(
            icon: Icons.storefront_outlined,
            title: 'No workers nearby',
            subtitle: 'Check back later or broaden your search.',
          )
        else
          SizedBox(
            height: AppConstants.homeMarketplacePreviewStripHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: workers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final w = workers[i];
                return SizedBox(
                  width: AppConstants.homeMarketplacePreviewCardWidth,
                  child: WorkerCard(
                    name: w.name,
                    services: resolveWorkerServiceLabels(
                      w,
                      idToName: serviceMap,
                    ),
                    rating: w.rating,
                    reviewCount: w.reviewCount,
                    distanceKm: w.distanceKm ?? 0,
                    avatarUrl: w.avatarUrl,
                    isVerified: w.verificationStatus,
                    showTrailingChevron: false,
                    onTap: () => context.push(Routes.workerProfile(w.id)),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ActiveServicesSection extends ConsumerWidget {
  const _ActiveServicesSection();

  static const _maxPreview = 3;

  static bool _isActive(ServiceRequest r) {
    if (r.cancelled) return false;
    switch (r.status) {
      case ServiceRequestStatus.bidAccepted:
      case ServiceRequestStatus.onTheWay:
      case ServiceRequestStatus.arrived:
      case ServiceRequestStatus.inProgress:
        return true;
      case ServiceRequestStatus.posted:
      case ServiceRequestStatus.workerAccepted:
      case ServiceRequestStatus.bidReceived:
      case ServiceRequestStatus.completed:
      case ServiceRequestStatus.cancelled:
      case ServiceRequestStatus.unknown:
        return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      myServiceRequestsProvider(ServiceRequestRole.customer),
    );

    return async.maybeWhen(
      data: (items) {
        final active = items.where(_isActive).toList();
        if (active.isEmpty) return const SizedBox.shrink();

        final preview = active.take(_maxPreview).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: active.length == 1
                  ? 'In Progress Job'
                  : 'In Progress Jobs',
              trailing: active.length > _maxPreview
                  ? TextButton(
                      onPressed: () => context.push(Routes.sentRequests),
                      child: const Text('See all'),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < preview.length; i++) ...[
              SentRequestTile(
                request: preview[i],
                onTap: () =>
                    context.push(Routes.sentRequestDetail(preview[i].id)),
              ),
              if (i < preview.length - 1) const SizedBox(height: 10),
            ],
            const SizedBox(height: 20),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _RequestedServicesSection extends ConsumerWidget {
  const _RequestedServicesSection();

  static const _maxPreview = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      myServiceRequestsProvider(ServiceRequestRole.customer),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Requested Services',
          trailing: async.maybeWhen(
            data: (list) => list.isEmpty
                ? null
                : TextButton(
                    onPressed: () => context.push(Routes.sentRequests),
                    child: const Text('See all'),
                  ),
            orElse: () => null,
          ),
        ),
        const SizedBox(height: 8),
        async.when(
          loading: () => const LoadingShimmer(height: 120),
          error: (_, _) => const EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load requests',
            subtitle: 'Pull to refresh and try again.',
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.outbox_outlined,
                title: 'No sent requests',
                subtitle: 'Book a worker from the marketplace to see it here.',
              );
            }
            final preview = items.take(_maxPreview).toList();
            return SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: preview.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final req = preview[i];
                  return SizedBox(
                    width: 280,
                    child: SentRequestTile(
                      request: req,
                      onTap: () =>
                          context.push(Routes.sentRequestDetail(req.id)),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
