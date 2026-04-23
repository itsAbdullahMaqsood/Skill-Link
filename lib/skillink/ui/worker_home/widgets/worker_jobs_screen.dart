import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/data/services/recent_worker_open_bid_storage.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/domain/models/open_job_post_bid.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/job_status_chip.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/discover_open_jobs_section.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/open_job_post_my_bid_tile.dart';
import 'package:skilllink/skillink/ui/worker_home/view_models/worker_earnings_view_model.dart';
import 'package:skilllink/skillink/ui/worker_home/view_models/worker_jobs_view_model.dart';
import 'package:skilllink/skillink/ui/service_requests/widgets/sent_requests_screen.dart';
import 'package:skilllink/skillink/utils/text_format.dart';

const _kInlineRequestCap = 3;
const _kRecentBidsCap = 3;

ServiceRequest? _pickPrimaryWorkerOngoingRequest(List<ServiceRequest> list) {
  final candidates = list
      .where((r) => r.showsAsWorkerOngoingJob)
      .toList(growable: false);
  if (candidates.isEmpty) return null;
  int rank(ServiceRequestStatus s) => switch (s) {
    ServiceRequestStatus.inProgress => 5,
    ServiceRequestStatus.arrived => 4,
    ServiceRequestStatus.onTheWay => 3,
    ServiceRequestStatus.bidAccepted => 2,
    ServiceRequestStatus.workerAccepted => 1,
    _ => 0,
  };
  candidates.sort((a, b) {
    final byRank = rank(b.status).compareTo(rank(a.status));
    if (byRank != 0) return byRank;
    final au = a.updatedAt ?? a.createdAt;
    final bu = b.updatedAt ?? b.createdAt;
    if (au == null && bu == null) return 0;
    if (au == null) return 1;
    if (bu == null) return -1;
    return bu.compareTo(au);
  });
  return candidates.first;
}

String _jobStatusChipKeyForServiceRequest(ServiceRequestStatus s) {
  return switch (s) {
    ServiceRequestStatus.posted => 'posted',
    ServiceRequestStatus.workerAccepted => 'workerAccepted',
    ServiceRequestStatus.bidReceived => 'bidReceived',
    ServiceRequestStatus.bidAccepted => 'bidAccepted',
    ServiceRequestStatus.onTheWay => 'onTheWay',
    ServiceRequestStatus.arrived => 'arrived',
    ServiceRequestStatus.inProgress => 'inProgress',
    ServiceRequestStatus.completed => 'completed',
    ServiceRequestStatus.cancelled => 'cancelledNoPenalty',
    ServiceRequestStatus.unknown => 'posted',
  };
}

class WorkerJobsScreen extends ConsumerWidget {
  const WorkerJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workerJobsViewModelProvider);
    final vm = ref.read(workerJobsViewModelProvider.notifier);
    final user = ref.watch(authViewModelProvider).user;
    final awardedSrIds =
        ref.watch(workerAwardedOpenJobServiceRequestIdsProvider);
    final srAsync = ref.watch(
      myServiceRequestsProvider(ServiceRequestRole.worker),
    );
    final activeServiceRequest = srAsync.maybeWhen(
      data: (list) {
        final forPick = state.activeJob != null
            ? list.where((r) => !awardedSrIds.contains(r.id)).toList()
            : list;
        return _pickPrimaryWorkerOngoingRequest(forPick);
      },
      orElse: () => null,
    );

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
      body: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingShimmer(height: 200),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(
                  myServiceRequestsProvider(ServiceRequestRole.worker),
                );
                ref.invalidate(discoverOpenJobPostsProvider);
                ref.invalidate(
                  myOpenJobPostsProvider(ServiceRequestRole.worker),
                );
                ref.invalidate(recentLocalWorkerOpenBidsProvider);
                await vm.refresh();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _GreetingCard(name: user?.name),
                  const SizedBox(height: 16),

                  const _SectionHeader(title: 'Open Jobs'),
                  const SizedBox(height: 8),
                  const DiscoverOpenJobsSection(),
                  const SizedBox(height: 20),

                  if (state.activeJob != null ||
                      activeServiceRequest != null) ...[
                    const _SectionHeader(title: 'In Progress Job'),
                    const SizedBox(height: 8),
                    if (state.activeJob != null)
                      _ActiveJobCard(
                        job: state.activeJob!,
                        onTap: () => context.push(
                          Routes.workerJobDetail(state.activeJob!.jobId),
                        ),
                      ),
                    if (state.activeJob != null && activeServiceRequest != null)
                      const SizedBox(height: 10),
                    if (activeServiceRequest != null)
                      _ActiveServiceRequestCard(
                        request: activeServiceRequest,
                        onTap: () => context.push(
                          Routes.receivedRequestDetail(activeServiceRequest.id),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],

                  const _IncomingRequestsSection(),
                  const SizedBox(height: 20),

                  _SectionHeader(
                    title: 'My Recent Bids',
                    trailing: TextButton(
                      onPressed: () => context.push(Routes.myBids),
                      child: const Text('See all'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _RecentBidsSection(),
                  const SizedBox(height: 20),

                  const _EarningsStatCard(),
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
                  'Ready to take on new jobs today?',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.construction_rounded, color: Colors.white, size: 44),
        ],
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
      children: [
        Text(title, style: AppTypography.titleLarge),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

class _ActiveServiceRequestCard extends StatelessWidget {
  const _ActiveServiceRequestCard({required this.request, required this.onTap});

  final ServiceRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = request.description.trim().isEmpty
        ? 'Service request'
        : request.description.trim();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.assignment_turned_in_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    request.serviceAddress,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            JobStatusChip(
              status: _jobStatusChipKeyForServiceRequest(request.status),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  const _ActiveJobCard({required this.job, required this.onTap});

  final Job job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(job.serviceType), color: AppColors.primary),
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
            const SizedBox(width: 8),
            JobStatusChip(status: job.status.name),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Open posts still accepting bids from the API, padded with on-device history
/// ([RecentWorkerOpenBidStorage]) so closed jobs stay visible as "recent".
class _RecentBidsSection extends ConsumerWidget {
  const _RecentBidsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(
      myOpenJobPostsProvider(ServiceRequestRole.worker),
    );
    final localAsync = ref.watch(recentLocalWorkerOpenBidsProvider);

    final localsSorted = [...(localAsync.valueOrNull ?? const [])]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    final postsLoading = postsAsync.isLoading && !postsAsync.hasValue;
    final localStillLoading = localAsync.isLoading && !localAsync.hasValue;
    if (postsLoading && (localStillLoading || localsSorted.isEmpty)) {
      return const SizedBox(height: 100, child: LoadingShimmer(height: 96));
    }

    final posts = postsAsync.valueOrNull ?? const <OpenJobPost>[];
    final active = posts
        .where((p) => p.status == OpenJobPostStatus.openForBids)
        .take(_kRecentBidsCap)
        .toList();
    final seenIds = active.map((p) => p.id).toSet();
    final filler = localsSorted
        .where((e) => !seenIds.contains(e.postId))
        .take(_kRecentBidsCap - active.length)
        .toList();

    if (active.isEmpty && filler.isEmpty) {
      if (postsAsync.hasError) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'Could not load bids',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        );
      }
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.gavel_outlined,
                size: 28,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 8),
              Text(
                'No active bids',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Placed bids appear here.',
                textAlign: TextAlign.center,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final widgets = <Widget>[];
    if (postsAsync.hasError && active.isEmpty && filler.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Could not refresh list. Showing bids saved on this device.',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ),
      );
    }
    for (var i = 0; i < active.length; i++) {
      widgets.add(OpenJobPostMyBidTile(post: active[i]));
      if (i < active.length - 1 || filler.isNotEmpty) {
        widgets.add(const SizedBox(height: 10));
      }
    }
    for (var i = 0; i < filler.length; i++) {
      widgets.add(_LocalRecentOpenJobBidTile(bid: filler[i]));
      if (i < filler.length - 1) {
        widgets.add(const SizedBox(height: 10));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}

class _LocalRecentOpenJobBidTile extends StatelessWidget {
  const _LocalRecentOpenJobBidTile({required this.bid});

  final LocalRecentOpenJobBid bid;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (bid.status) {
      OpenJobPostBidStatus.accepted => (
        AppColors.success.withValues(alpha: 0.14),
        AppColors.success,
      ),
      OpenJobPostBidStatus.rejected => (
        AppColors.danger.withValues(alpha: 0.12),
        AppColors.danger,
      ),
      _ => (AppColors.primary.withValues(alpha: 0.12), AppColors.primary),
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(Routes.openJobPostDetail(bid.postId)),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.descriptionPreview,
                      style: AppTypography.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Saved on device · ${bid.status.displayLabel}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${bid.currency} ${bid.amount}',
                  style: AppTypography.labelMedium.copyWith(
                    color: fg,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarningsStatCard extends ConsumerWidget {
  const _EarningsStatCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsState = ref.watch(workerEarningsViewModelProvider);

    return GestureDetector(
      onTap: () => context.push(Routes.workerEarnings),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withValues(alpha: 0.08),
              AppColors.success.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total earned',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  earningsState.isLoading
                      ? const SizedBox(
                          width: 80,
                          height: 20,
                          child: LoadingShimmer(height: 20),
                        )
                      : Text(
                          'Rs. ${_formatCurrency(earningsState.summary?.totalNet ?? 0)}',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.success,
                          ),
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

  static String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }
}

class _IncomingRequestsSection extends ConsumerWidget {
  const _IncomingRequestsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final awardedSrIds =
        ref.watch(workerAwardedOpenJobServiceRequestIdsProvider);
    final async = ref.watch(
      myServiceRequestsProvider(ServiceRequestRole.worker),
    );

    final directBookings = async.maybeWhen(
      data: (list) => list
          .where(
            (r) =>
                !r.isTerminal &&
                !r.showsAsWorkerOngoingJob &&
                !awardedSrIds.contains(r.id),
          )
          .toList(),
      orElse: () => const <ServiceRequest>[],
    );

    final loading = async.isLoading && !async.hasValue;
    final hasAny = directBookings.isNotEmpty;
    final hasOverflow = directBookings.length > _kInlineRequestCap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Incoming Requests',
          trailing: hasAny && hasOverflow
              ? TextButton(
                  onPressed: () => context.go(Routes.workerIncoming),
                  child: const Text('See all'),
                )
              : null,
        ),
        const SizedBox(height: 8),
        if (!hasAny && loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (!hasAny)
          const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No requests yet',
            subtitle: 'Direct bookings from homeowners will appear here.',
          )
        else
          ..._buildInlineItems(context, directBookings),
      ],
    );
  }

  List<Widget> _buildInlineItems(
    BuildContext context,
    List<ServiceRequest> requests,
  ) {
    final widgets = <Widget>[];
    var remaining = _kInlineRequestCap;

    for (final req in requests) {
      if (remaining == 0) break;
      widgets.add(
        SentRequestTile(
          request: req,
          onTap: () => context.push(Routes.receivedRequestDetail(req.id)),
        ),
      );
      widgets.add(const SizedBox(height: 10));
      remaining--;
    }

    if (widgets.isNotEmpty && widgets.last is SizedBox) {
      widgets.removeLast();
    }
    return widgets;
  }
}

IconData _iconFor(String type) => switch (type.toLowerCase()) {
  'electrician' || 'electrical' => Icons.electrical_services_rounded,
  'plumber' || 'plumbing' => Icons.plumbing_rounded,
  'hvac' || 'ac' => Icons.ac_unit_rounded,
  'carpenter' || 'carpentry' => Icons.carpenter_rounded,
  _ => Icons.handyman_rounded,
};
