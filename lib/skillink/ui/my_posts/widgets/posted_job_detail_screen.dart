import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/job_media_type.dart';
import 'package:skilllink/skillink/domain/models/job_post_tag.dart';
import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/domain/models/posted_job_bid.dart';
import 'package:skilllink/skillink/domain/models/posted_job_status.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/chat/chat_entry.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/secondary_button.dart';
import 'package:skilllink/skillink/ui/my_posts/view_models/posted_job_detail_view_model.dart';
import 'package:skilllink/skillink/ui/my_posts/widgets/counter_offer_dialog.dart';
import 'package:skilllink/skillink/ui/post_job/widgets/post_job_sheet.dart';
import 'package:skilllink/skillink/utils/app_messenger.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';
import 'package:skilllink/skillink/utils/text_format.dart';
import 'package:skilllink/skillink/utils/trade_icon.dart';
import 'package:video_player/video_player.dart';

final _workerByIdProvider =
    FutureProvider.autoDispose.family<Worker?, String>((ref, id) async {
  final res = await ref.watch(workerRepositoryProvider).getWorker(id);
  return res.valueOrNull;
});

String _avatarInitials(String? name, String fallbackId) {
  final source = (name == null || name.trim().isEmpty) ? fallbackId : name.trim();
  if (source.isEmpty) return '?';
  final take = source.length >= 2 ? 2 : 1;
  return source.substring(0, take).toUpperCase();
}

class PostedJobDetailScreen extends ConsumerWidget {
  const PostedJobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postedJobDetailViewModelProvider(jobId));
    final vm = ref.read(postedJobDetailViewModelProvider(jobId).notifier);
    final user = ref.watch(authViewModelProvider).user;
    final job = state.job;

    if (state.isLoading && job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posted job')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posted job')),
        body: Center(child: Text(state.errorMessage ?? 'Not found')),
      );
    }

    final isOwner = user?.id == job.homeownerId;
    final canEdit = isOwner &&
        job.status == PostedJobStatus.open &&
        job.acceptedBidId == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(job.title, style: AppTypography.titleLarge),
        actions: [
          if (canEdit) ...[
            IconButton(
              tooltip: 'Edit',
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => PostJobSheet(editJob: job),
                );
              },
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: () async {
                final pendingWorkerBids = state.bids
                    .where((b) =>
                        b.offeredBy == PostedBidOfferedBy.worker &&
                        b.status == PostedBidStatus.pending)
                    .length;
                final body = pendingWorkerBids == 0
                    ? 'No bids yet — this post will be removed.'
                    : pendingWorkerBids == 1
                        ? '1 worker has bid on this post. Their bid will be marked rejected.'
                        : '$pendingWorkerBids workers have bid on this post. Their bids will be marked rejected.';
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete this post?'),
                    content: Text(body),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok != true || !context.mounted) return;
                final err = await vm.deletePost();
                if (!context.mounted) return;
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                } else {
                  context.pop();
                  appScaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(content: Text('Post deleted.')),
                  );
                }
              },
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Icon(TradeIcon.forTrade(job.tag.serviceTypeSlug), color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                TextFormat.trade(job.tag.serviceTypeSlug),
                style: AppTypography.titleLarge,
              ),
              const Spacer(),
              Text(job.status.displayLabel, style: AppTypography.labelLarge),
            ],
          ),
          const SizedBox(height: 12),
          Text(job.title, style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          if (job.descriptionText != null && job.descriptionText!.isNotEmpty)
            Text(job.descriptionText!, style: AppTypography.bodyMedium),
          if (job.media.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: job.media.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final m = job.media[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: m.type == JobMediaType.video
                          ? _VideoThumb(url: m.url)
                          : CachedNetworkImage(
                              imageUrl: m.url,
                              fit: BoxFit.cover,
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('Bids', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          ...[
            for (final b in state.bids)
              if (b.status != PostedBidStatus.withdrawn)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PostedBidTile(
                    job: job,
                    bid: b,
                    isOwner: isOwner,
                    onAccept: isOwner &&
                            job.status == PostedJobStatus.open &&
                            b.offeredBy == PostedBidOfferedBy.worker &&
                            b.status == PostedBidStatus.pending
                        ? () async {
                            final go = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Accept this bid?'),
                                content: Text(
                                  'Visiting Rs ${b.visitingCharges.toStringAsFixed(0)} + '
                                  'job Rs ${b.jobChargesEstimate.toStringAsFixed(0)}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Accept'),
                                  ),
                                ],
                              ),
                            );
                            if (go != true || !context.mounted) return;
                            final r = await vm.acceptBid(b.bidId);
                            if (!context.mounted) return;
                            if (r.error != null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(r.error!)));
                            } else if (r.trackingJobId != null) {
                              context.pushReplacement(
                                Routes.jobTracking(r.trackingJobId!),
                              );
                            }
                          }
                        : null,
                    onReject: isOwner &&
                            job.status == PostedJobStatus.open &&
                            b.status == PostedBidStatus.pending &&
                            b.offeredBy == PostedBidOfferedBy.worker
                        ? () async {
                            final err = await vm.rejectBid(b.bidId);
                            if (!context.mounted) return;
                            if (err != null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(err)));
                            }
                          }
                        : null,
                    onCounter: isOwner &&
                            job.status == PostedJobStatus.open &&
                            b.offeredBy == PostedBidOfferedBy.worker &&
                            b.status == PostedBidStatus.pending
                        ? () async {
                            final r = await showCounterOfferDialog(context);
                            if (r == null || !context.mounted) return;
                            final err = await vm.counterOffer(
                              visiting: r.visiting,
                              jobEstimate: r.jobEstimate,
                              note: r.note,
                            );
                            if (!context.mounted) return;
                            if (err != null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(err)));
                            }
                          }
                        : null,
                    onWithdrawCounterOffer: isOwner &&
                            job.status == PostedJobStatus.open &&
                            b.offeredBy == PostedBidOfferedBy.homeowner &&
                            b.status == PostedBidStatus.pending
                        ? () async {
                            final go = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Withdraw counter-offer?'),
                                content: const Text(
                                  'Workers will no longer see this offer.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Keep'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Withdraw'),
                                  ),
                                ],
                              ),
                            );
                            if (go != true || !context.mounted) return;
                            final err =
                                await vm.withdrawOwnCounterOffer(b.bidId);
                            if (!context.mounted) return;
                            if (err != null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(err)));
                            }
                          }
                        : null,
                    onAcceptCounterOffer: !isOwner &&
                            user?.role == UserRole.worker &&
                            job.status == PostedJobStatus.open &&
                            b.offeredBy == PostedBidOfferedBy.homeowner &&
                            b.status == PostedBidStatus.pending &&
                            state.bids.any((x) =>
                                x.workerId == user?.id &&
                                x.status == PostedBidStatus.pending)
                        ? () async {
                            final go = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Accept counter-offer?'),
                                content: Text(
                                  'You will be assigned this job at:\n'
                                  'Visiting Rs ${b.visitingCharges.toStringAsFixed(0)} + '
                                  'job Rs ${b.jobChargesEstimate.toStringAsFixed(0)}.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Accept'),
                                  ),
                                ],
                              ),
                            );
                            if (go != true || !context.mounted) return;
                            final r = await vm.acceptCounterOffer(b.bidId);
                            if (!context.mounted) return;
                            if (r.error != null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(r.error!)));
                            } else if (r.trackingJobId != null) {
                              context.pushReplacement(
                                Routes.jobTracking(r.trackingJobId!),
                              );
                            }
                          }
                        : null,
                    onRejectCounterOffer: !isOwner &&
                            user?.role == UserRole.worker &&
                            job.status == PostedJobStatus.open &&
                            b.offeredBy == PostedBidOfferedBy.homeowner &&
                            b.status == PostedBidStatus.pending &&
                            state.bids.any((x) =>
                                x.workerId == user?.id &&
                                x.status == PostedBidStatus.pending)
                        ? () async {
                            final err = await vm.rejectCounterOffer(b.bidId);
                            if (!context.mounted) return;
                            if (err != null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(err)));
                            }
                          }
                        : null,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _PostedBidTile extends ConsumerWidget {
  const _PostedBidTile({
    required this.job,
    required this.bid,
    required this.isOwner,
    this.onAccept,
    this.onReject,
    this.onCounter,
    this.onWithdrawCounterOffer,
    this.onAcceptCounterOffer,
    this.onRejectCounterOffer,
  });

  final PostedJob job;
  final PostedJobBid bid;
  final bool isOwner;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCounter;

  final VoidCallback? onWithdrawCounterOffer;

  final VoidCallback? onAcceptCounterOffer;
  final VoidCallback? onRejectCounterOffer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wid = bid.workerId;
    final workerAsync =
        wid != null ? ref.watch(_workerByIdProvider(wid)) : null;
    final worker = workerAsync?.valueOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (wid != null && bid.offeredBy == PostedBidOfferedBy.worker)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: RoundAvatar(
                  url: worker?.avatarUrl,
                  radius: 20,
                  placeholder: Text(_avatarInitials(worker?.name, wid)),
                ),
                title: Text(worker?.name ?? 'Worker'),
                subtitle: Text(
                  '${worker != null ? TextFormat.trade(worker.skillTypes.isNotEmpty ? worker.skillTypes.first : '') : ''}'
                  '${worker != null && worker.skillTypes.isNotEmpty ? ' · ' : ''}'
                  'ETA ~ ${bid.etaMinutes} min',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Message',
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      onPressed: worker == null
                          ? null
                          : () => ChatEntry.openWithWorker(
                                context,
                                ref,
                                worker: worker,
                              ),
                    ),
                    IconButton(
                      tooltip: 'Open profile',
                      icon: const Icon(Icons.person_search_outlined),
                      onPressed: () =>
                          context.push(Routes.workerProfile(wid)),
                    ),
                  ],
                ),
              )
            else
              Text(
                bid.offeredBy == PostedBidOfferedBy.homeowner
                    ? 'Your counter-offer'
                    : 'Bid',
                style: AppTypography.labelLarge,
              ),
            Text(
              'Visiting Rs ${bid.visitingCharges.toStringAsFixed(0)} · '
              'Job Rs ${bid.jobChargesEstimate.toStringAsFixed(0)}',
              style: AppTypography.bodyMedium,
            ),
            if (bid.note != null && bid.note!.isNotEmpty)
              Text(bid.note!, style: AppTypography.bodySmall),
            Text(
              'Status: ${bid.status.displayLabel}',
              style: AppTypography.labelMedium,
            ),
            if (isOwner && onAccept != null) ...[
              const SizedBox(height: 8),
              PrimaryButton(label: 'Accept', onPressed: onAccept),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Reject',
                      onPressed: onReject,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SecondaryButton(
                      label: 'Counter',
                      onPressed: onCounter,
                    ),
                  ),
                ],
              ),
            ],
            if (onWithdrawCounterOffer != null) ...[
              const SizedBox(height: 8),
              SecondaryButton(
                label: 'Withdraw',
                onPressed: onWithdrawCounterOffer,
              ),
            ],
            if (onAcceptCounterOffer != null) ...[
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Accept counter-offer',
                onPressed: onAcceptCounterOffer,
              ),
              if (onRejectCounterOffer != null) ...[
                const SizedBox(height: 8),
                SecondaryButton(
                  label: 'Decline',
                  onPressed: onRejectCounterOffer,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _VideoThumb extends StatefulWidget {
  const _VideoThumb({required this.url});

  final String url;

  @override
  State<_VideoThumb> createState() => _VideoThumbState();
}

class _VideoThumbState extends State<_VideoThumb> {
  VideoPlayerController? _c;
  bool _playing = false;
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _c = ctrl;
    ctrl.addListener(_onPlayStateChanged);
    ctrl.initialize().then(
      (_) {
        if (mounted) setState(() {});
      },
      onError: (Object _, StackTrace _) {
        if (mounted) setState(() => _initFailed = true);
      },
    );
  }

  void _onPlayStateChanged() {
    final isPlaying = _c?.value.isPlaying ?? false;
    if (isPlaying != _playing) {
      setState(() => _playing = isPlaying);
    }
  }

  @override
  void dispose() {
    _c?.removeListener(_onPlayStateChanged);
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initFailed) {
      return const ColoredBox(
        color: Colors.black26,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.white70,
            size: 36,
          ),
        ),
      );
    }
    final c = _c;
    if (c == null || !c.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black26,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c)),
        IconButton(
          icon: Icon(
            _playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
            size: 48,
            color: Colors.white,
          ),
          onPressed: () {
            if (_playing) {
              c.pause();
            } else {
              c.play();
            }
          },
        ),
      ],
    );
  }
}
