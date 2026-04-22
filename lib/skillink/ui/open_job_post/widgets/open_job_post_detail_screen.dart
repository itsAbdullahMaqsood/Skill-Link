import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/domain/models/open_job_post_bid.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/secondary_button.dart';
import 'package:skilllink/skillink/ui/chat/chat_entry.dart';
import 'package:skilllink/skillink/ui/marketplace/view_models/worker_profile_view_model.dart';
import 'package:skilllink/skillink/ui/open_job_post/view_models/open_job_post_actions_controller.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/open_job_post_bid_sheet.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';

const Duration _kPollInterval = Duration(seconds: 10);

class OpenJobPostDetailScreen extends ConsumerStatefulWidget {
  const OpenJobPostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<OpenJobPostDetailScreen> createState() =>
      _OpenJobPostDetailScreenState();
}

class _OpenJobPostDetailScreenState
    extends ConsumerState<OpenJobPostDetailScreen>
    with WidgetsBindingObserver {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      ref.invalidate(openJobPostByIdProvider(widget.postId));
      ref.invalidate(openJobPostBidsProvider(widget.postId));
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _stopPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kPollInterval, (_) {
      if (!mounted) return;
      final busy = ref
          .read(openJobPostActionsControllerProvider(widget.postId))
          .isBusy;
      if (busy) return;
      ref.invalidate(openJobPostByIdProvider(widget.postId));
      ref.invalidate(openJobPostBidsProvider(widget.postId));
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(openJobPostByIdProvider(widget.postId));
    final bidsAsync = ref.watch(openJobPostBidsProvider(widget.postId));
    final viewerId = ref.watch(authViewModelProvider).user?.id;
    final actionsState =
        ref.watch(openJobPostActionsControllerProvider(widget.postId));

    ref.listen<OpenJobPostActionsState>(
      openJobPostActionsControllerProvider(widget.postId),
      (prev, next) {
        final msg = next.errorMessage;
        if (msg == null || msg == prev?.errorMessage) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(msg)));
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Job Post', style: AppTypography.headlineMedium),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(openJobPostBidsProvider(widget.postId));
          ref.invalidate(openJobPostByIdProvider(widget.postId));
          await ref.read(
            openJobPostByIdProvider(widget.postId).future,
          );
        },
        child: postAsync.when(
          data: (post) => _DetailBody(
            post: post,
            bidsAsync: bidsAsync,
            viewerId: viewerId,
            isBusy: actionsState.isBusy,
            runningAction: actionsState.runningAction,
          ),
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              LoadingShimmer(height: 90),
              SizedBox(height: 16),
              LoadingShimmer(height: 160),
              SizedBox(height: 16),
              LoadingShimmer(height: 240),
            ],
          ),
          error: (e, _) => _ErrorView(message: '$e'),
        ),
      ),
    );
  }
}


class _DetailBody extends ConsumerWidget {
  const _DetailBody({
    required this.post,
    required this.bidsAsync,
    required this.viewerId,
    required this.isBusy,
    required this.runningAction,
  });

  final OpenJobPost post;
  final AsyncValue<List<OpenJobPostBid>> bidsAsync;
  final String? viewerId;
  final bool isBusy;
  final OpenJobPostActionKind runningAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthor =
        viewerId != null && viewerId == post.requestingUserId;
    final canBid = post.status == OpenJobPostStatus.openForBids;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _HeaderCard(post: post),
        if (post.status == OpenJobPostStatus.cancelled) ...[
          const SizedBox(height: 12),
          _CancelledBanner(cancelledAt: post.updatedAt),
        ] else if (post.status == OpenJobPostStatus.workerSelected ||
            post.status == OpenJobPostStatus.awarded) ...[
          const SizedBox(height: 12),
          _AwardedBanner(post: post, viewerIsAuthor: isAuthor),
        ],
        const SizedBox(height: 16),
        _SectionLabel('Description'),
        const SizedBox(height: 6),
        Text(
          post.description.trim().isEmpty
              ? 'No description provided.'
              : post.description,
          style: AppTypography.bodyMedium,
        ),
        if (post.photos.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionLabel('Photos'),
          const SizedBox(height: 8),
          _PhotosStrip(paths: post.photos),
        ],
        const SizedBox(height: 20),
        _SectionLabel('Schedule'),
        const SizedBox(height: 8),
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Date',
          value: post.scheduledServiceDate.isEmpty
              ? 'Flexible'
              : post.scheduledServiceDate,
        ),
        _InfoRow(
          icon: Icons.access_time_rounded,
          label: 'Time slot',
          value:
              '${post.timeSlot.startTime} – ${post.timeSlot.endTime}',
        ),
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value: post.serviceAddress,
        ),
        _InfoRow(
          icon: Icons.payments_outlined,
          label: 'Payment',
          value: post.paymentMethod == ServiceRequestPaymentMethod.cash
              ? 'Cash on completion'
              : 'In-app payment',
        ),
        const SizedBox(height: 20),
        _SectionLabel(isAuthor ? 'Bids' : 'Your bid'),
        const SizedBox(height: 8),
        bidsAsync.when(
          data: (bids) => _BidList(
            post: post,
            bids: bids,
            viewerId: viewerId,
            isAuthor: isAuthor,
            canBid: canBid,
            isBusy: isBusy,
            runningAction: runningAction,
          ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text(
            'Could not load bids: $e',
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 24),
        if (isAuthor && canBid)
          _CancelPostButton(postId: post.id, isBusy: isBusy),
      ],
    );
  }
}


class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.post});
  final OpenJobPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Open Job Post', style: AppTypography.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '#${_shortId(post.id)}',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          _StatusChip(status: post.status),
        ],
      ),
    );
  }

  static String _shortId(String id) =>
      id.length <= 8 ? id : id.substring(0, 8);
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final OpenJobPostStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      OpenJobPostStatus.openForBids => (
          AppColors.primary.withValues(alpha: 0.14),
          AppColors.primary,
        ),
      OpenJobPostStatus.workerSelected ||
      OpenJobPostStatus.awarded =>
        (
          AppColors.success.withValues(alpha: 0.14),
          AppColors.success,
        ),
      OpenJobPostStatus.cancelled =>
        (AppColors.danger.withValues(alpha: 0.14), AppColors.danger),
      OpenJobPostStatus.closed ||
      OpenJobPostStatus.unknown =>
        (
          AppColors.border.withValues(alpha: 0.4),
          AppColors.textMuted,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayLabel,
        style: AppTypography.labelMedium.copyWith(color: fg),
      ),
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner({required this.cancelledAt});
  final DateTime? cancelledAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_outlined,
              size: 20, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This post was cancelled',
                  style: AppTypography.titleLarge
                      .copyWith(color: AppColors.danger, fontSize: 14),
                ),
                if (cancelledAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'on ${_fmt(cancelledAt!)}',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _AwardedBanner extends StatelessWidget {
  const _AwardedBanner({required this.post, required this.viewerIsAuthor});
  final OpenJobPost post;
  final bool viewerIsAuthor;

  @override
  Widget build(BuildContext context) {
    final srId = post.serviceRequestId;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 20, color: AppColors.success),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'A worker has been selected for this post',
                  style: AppTypography.titleLarge
                      .copyWith(color: AppColors.success, fontSize: 14),
                ),
              ),
            ],
          ),
          if (srId != null && srId.isNotEmpty) ...[
            const SizedBox(height: 10),
            SecondaryButton(
              label: viewerIsAuthor ? 'Open service request' : 'Open job',
              icon: Icons.arrow_forward_rounded,
              onPressed: () =>
                  context.push(Routes.sentRequestDetail(srId)),
            ),
          ],
        ],
      ),
    );
  }
}


class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: AppTypography.labelMedium
            .copyWith(color: AppColors.textMuted),
      );
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}


class _PhotosStrip extends StatelessWidget {
  const _PhotosStrip({required this.paths});
  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final url = _resolve(paths[i]);
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: url,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(width: 96, height: 96, color: AppColors.border),
              errorWidget: (_, __, ___) => Container(
                width: 96,
                height: 96,
                color: AppColors.border,
                child: const Icon(Icons.broken_image_outlined,
                    color: AppColors.textMuted),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _resolve(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final base = AppConstants.apiBaseUrl;
    final trimmedBase =
        base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final suffix = path.startsWith('/') ? path : '/$path';
    return '$trimmedBase$suffix';
  }
}


class _BidList extends ConsumerWidget {
  const _BidList({
    required this.post,
    required this.bids,
    required this.viewerId,
    required this.isAuthor,
    required this.canBid,
    required this.isBusy,
    required this.runningAction,
  });

  final OpenJobPost post;
  final List<OpenJobPostBid> bids;
  final String? viewerId;
  final bool isAuthor;
  final bool canBid;
  final bool isBusy;
  final OpenJobPostActionKind runningAction;

  bool _viewerHasBid() {
    final v = viewerId;
    if (v == null || v.isEmpty) return false;
    return bids.any((b) => b.workerId == v);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bids.isEmpty) {
      if (isAuthor) {
        return _EmptyHint(
          icon: Icons.gavel_outlined,
          title: canBid
              ? 'No bids yet'
              : 'No bids were placed before the post closed.',
          subtitle: canBid
              ? 'Workers in your area are being notified. '
                  'Bids usually arrive within a few hours.'
              : '',
        );
      }
      return Column(
        children: [
          _EmptyHint(
            icon: Icons.gavel_outlined,
            title: canBid
                ? "You haven't bid yet"
                : "You didn't place a bid on this post",
            subtitle: canBid
                ? 'Submit your quote below. The homeowner can accept any '
                    'pending bid at any time.'
                : '',
          ),
          if (canBid) ...[
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Place a bid',
              icon: Icons.gavel_rounded,
              isLoading: runningAction == OpenJobPostActionKind.submitBid,
              onPressed: isBusy
                  ? null
                  : () =>
                      OpenJobPostBidSheet.show(context, post: post),
            ),
          ],
        ],
      );
    }

    final showPlaceBidCta =
        !isAuthor && canBid && !_viewerHasBid();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final bid in bids)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _BidTile(
              post: post,
              bid: bid,
              viewerId: viewerId,
              isAuthor: isAuthor,
              canAct: canBid,
              isBusy: isBusy,
              runningAction: runningAction,
            ),
          ),
        if (showPlaceBidCta) ...[
          const SizedBox(height: 4),
          PrimaryButton(
            label: 'Place a bid',
            icon: Icons.gavel_rounded,
            isLoading: runningAction == OpenJobPostActionKind.submitBid,
            onPressed: isBusy
                ? null
                : () => OpenJobPostBidSheet.show(context, post: post),
          ),
        ],
      ],
    );
  }
}

class _BidTile extends ConsumerWidget {
  const _BidTile({
    required this.post,
    required this.bid,
    required this.viewerId,
    required this.isAuthor,
    required this.canAct,
    required this.isBusy,
    required this.runningAction,
  });

  final OpenJobPost post;
  final OpenJobPostBid bid;
  final String? viewerId;
  final bool isAuthor;
  final bool canAct;
  final bool isBusy;
  final OpenJobPostActionKind runningAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwnBid =
        viewerId != null &&
        viewerId!.isNotEmpty &&
        bid.workerId == viewerId;
    final isAcceptedBid =
        post.awardedBidId != null && post.awardedBidId == bid.id;
    final tile = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAcceptedBid ? AppColors.success : AppColors.border,
          width: isAcceptedBid ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAuthor)
            _BidderHeader(
              workerId: bid.workerId,
              canChat: bid.status == OpenJobPostBidStatus.pending,
            ),
          if (isAuthor) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${bid.currency} ${bid.amount}',
                  style: AppTypography.titleLarge,
                ),
              ),
              _BidStatusChip(status: bid.status),
            ],
          ),
          if (bid.note.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(bid.note, style: AppTypography.bodyMedium),
          ],
          const SizedBox(height: 4),
          Text(
            'Submitted ${_formatWhen(bid.createdAt)}',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textMuted),
          ),
          if (isAuthor &&
              canAct &&
              bid.status == OpenJobPostBidStatus.pending) ...[
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Accept this bid',
              icon: Icons.check_rounded,
              isLoading: runningAction == OpenJobPostActionKind.selectBid,
              onPressed: isBusy
                  ? null
                  : () => _confirmSelect(context, ref),
            ),
          ],
          if (!isAuthor &&
              isOwnBid &&
              canAct &&
              bid.status == OpenJobPostBidStatus.pending) ...[
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Update your bid',
              icon: Icons.edit_outlined,
              onPressed: isBusy
                  ? null
                  : () => OpenJobPostBidSheet.show(
                        context,
                        post: post,
                        existingBid: bid,
                      ),
            ),
          ],
        ],
      ),
    );
    return tile;
  }

  Future<void> _confirmSelect(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select this bid?'),
        content: Text(
          "This will close your post to further bidding and create a "
          "service request with this worker for ${bid.currency} ${bid.amount}. "
          "Other pending bids will be automatically rejected.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Select bid'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!context.mounted) return;

    final controller =
        ref.read(openJobPostActionsControllerProvider(post.id).notifier);
    final outcome = await controller.selectBid(bidId: bid.id);
    if (!context.mounted) return;
    if (!outcome.isSuccess) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bid accepted. A service request has been created.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.push(Routes.sentRequestDetail(outcome.serviceRequestId!));
  }

  static String _formatWhen(DateTime? d) {
    if (d == null) return 'just now';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _BidderHeader extends ConsumerWidget {
  const _BidderHeader({required this.workerId, required this.canChat});

  final String workerId;

  final bool canChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workerProfileViewModelProvider(workerId));
    final worker = state.worker;
    final name = worker?.name ?? 'Worker';
    final avatar = worker?.avatarUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RoundAvatar(url: avatar, radius: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.titleLarge
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (worker != null && worker.rating > 0)
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Color(0xFFF2B84B),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      worker.rating.toStringAsFixed(1),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'View profile',
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          onPressed: () => context.push(
            Routes.workerProfile(workerId, hideBook: true),
          ),
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.border.withValues(alpha: 0.25),
            padding: const EdgeInsets.all(8),
          ),
        ),
        if (canChat) ...[
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Chat',
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            onPressed: worker == null
                ? null
                : () => ChatEntry.openWithWorker(
                      context,
                      ref,
                      worker: worker,
                    ),
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ],
    );
  }
}

class _BidStatusChip extends StatelessWidget {
  const _BidStatusChip({required this.status});
  final OpenJobPostBidStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      OpenJobPostBidStatus.pending => (
          AppColors.primary.withValues(alpha: 0.12),
          AppColors.primary,
        ),
      OpenJobPostBidStatus.accepted => (
          AppColors.success.withValues(alpha: 0.14),
          AppColors.success,
        ),
      OpenJobPostBidStatus.rejected => (
          AppColors.danger.withValues(alpha: 0.12),
          AppColors.danger,
        ),
      OpenJobPostBidStatus.withdrawn ||
      OpenJobPostBidStatus.unknown =>
        (
          AppColors.border.withValues(alpha: 0.4),
          AppColors.textMuted,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayLabel,
        style: AppTypography.labelMedium.copyWith(color: fg, fontSize: 11),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge.copyWith(fontSize: 14)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _CancelPostButton extends ConsumerWidget {
  const _CancelPostButton({required this.postId, required this.isBusy});
  final String postId;
  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: isBusy
          ? null
          : () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Cancel this post?'),
                  content: const Text(
                    'Workers will no longer see it in their feed and any '
                    'pending bids will be closed. This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Keep post'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Cancel post'),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
              if (!context.mounted) return;
              final ok = await ref
                  .read(
                    openJobPostActionsControllerProvider(postId).notifier,
                  )
                  .cancelPost();
              if (!context.mounted || !ok) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post cancelled.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
      icon: const Icon(Icons.cancel_outlined, color: AppColors.danger),
      label: const Text(
        'Cancel this post',
        style: TextStyle(color: AppColors.danger),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Text(
          'Could not load this post',
          textAlign: TextAlign.center,
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
