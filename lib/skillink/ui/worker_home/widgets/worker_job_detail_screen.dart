import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/domain/models/bid.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/ui/chat/chat_entry.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/cancel_job_dialog.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/job_status_chip.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/secondary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/status_timeline.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/worker_home/view_models/worker_job_detail_view_model.dart';
import 'package:skilllink/skillink/ui/worker_home/widgets/bid_modal.dart';
import 'package:skilllink/skillink/utils/text_format.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerJobDetailScreen extends ConsumerWidget {
  const WorkerJobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workerJobDetailViewModelProvider(jobId));
    final vm = ref.read(workerJobDetailViewModelProvider(jobId).notifier);

    ref.listen(
      workerJobDetailViewModelProvider(jobId).select((s) => s.errorMessage),
      (_, msg) {
        if (msg != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(msg)));
          vm.clearError();
        }
      },
    );

    ref.listen(
      workerJobDetailViewModelProvider(jobId).select((s) => s.job?.status),
      (prev, next) {
        if (next != JobStatus.completed) return;
        if (prev == null || prev == JobStatus.completed) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.push(Routes.completionPrompt(jobId));
          }
        });
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Job Detail', style: AppTypography.headlineMedium),
      ),
      body: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingShimmer(height: 300),
            )
          : state.job == null
              ? ErrorView(
                  message: state.errorMessage ?? 'Job not found.',
                  onRetry: () =>
                      ref.read(workerJobDetailViewModelProvider(jobId).notifier).retry(),
                )
              : _Body(job: state.job!, vm: vm, isBusy: state.isBusy),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.job, required this.vm, required this.isBusy});

  final Job job;
  final WorkerJobDetailViewModel vm;
  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCancel =
        job.status.isActive && job.status.index < JobStatus.inProgress.index;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
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
              Row(
                children: [
                  Text(TextFormat.trade(job.serviceType),
                      style: AppTypography.headlineSmall),
                  const Spacer(),
                  JobStatusChip(status: job.status.name),
                ],
              ),
              const SizedBox(height: 8),
              Text(job.description, style: AppTypography.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${job.address.street}, ${job.address.area}, '
                      '${job.address.city}',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ActionChip(
                    icon: Icons.navigation_rounded,
                    label: 'Navigate',
                    onTap: () => _openMaps(job),
                  ),
                  const SizedBox(width: 10),
                  _ActionChip(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Message',
                    onTap: () => ChatEntry.openWithPeer(
                      context,
                      ref,
                      peerId: job.userId,
                      peerName: 'Homeowner',
                      peerRole: UserRole.homeowner,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ActionChip(
                    icon: Icons.phone_rounded,
                    label: 'Call',
                    onTap: () => _callHomeowner(),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        StatusTimeline(status: job.status),

        const SizedBox(height: 20),

        if (job.bidHistory.isNotEmpty) ...[
          _WorkerBidCard(
            job: job,
            isBusy: isBusy,
            onAcceptCounter: () => vm.acceptBid(),
            onCounterOffer: () => _showCounterModal(context),
          ),
          const SizedBox(height: 16),
        ],

        if (_canAdvance(job.status)) ...[
          PrimaryButton(
            label: _nextLabel(job.status),
            icon: _nextIcon(job.status),
            onPressed: isBusy ? null : () => vm.advanceStatus(),
            isLoading: isBusy,
          ),
          const SizedBox(height: 10),
        ],

        if (job.status == JobStatus.completed && job.finalPrice != null) ...[
          _InvoiceCard(job: job),
          const SizedBox(height: 16),
        ],

        if (canCancel)
          SecondaryButton(
            label: 'Cancel Job',
            onPressed: isBusy
                ? null
                : () => _showCancelDialog(context),
          ),
      ],
    );
  }

  void _showCounterModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BidModal(
        job: job,
        isCounterOffer: true,
        onSubmit: (amount) {
          vm.submitBid(amount);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final confirmed = await CancelJobDialog.show(
      context,
      jobCreatedAt: job.createdAt,
    );
    if (confirmed) vm.cancelJob();
  }

  Future<void> _openMaps(Job job) async {
    final query = Uri.encodeComponent(
      '${job.address.street}, ${job.address.area}, ${job.address.city}',
    );
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _callHomeowner() async {
    final uri = Uri(scheme: 'tel', path: '+923001234567');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  bool _canAdvance(JobStatus s) => switch (s) {
        JobStatus.bidAccepted ||
        JobStatus.onTheWay ||
        JobStatus.arrived ||
        JobStatus.inProgress =>
          true,
        _ => false,
      };

  String _nextLabel(JobStatus s) => switch (s) {
        JobStatus.bidAccepted => 'On My Way',
        JobStatus.onTheWay => 'I\'ve Arrived',
        JobStatus.arrived => 'Start Work',
        JobStatus.inProgress => 'Mark Complete',
        _ => '',
      };

  IconData _nextIcon(JobStatus s) => switch (s) {
        JobStatus.bidAccepted => Icons.directions_car_rounded,
        JobStatus.onTheWay => Icons.pin_drop_rounded,
        JobStatus.arrived => Icons.play_circle_rounded,
        JobStatus.inProgress => Icons.check_circle_rounded,
        _ => Icons.arrow_forward_rounded,
      };
}

class _WorkerBidCard extends StatelessWidget {
  const _WorkerBidCard({
    required this.job,
    required this.isBusy,
    required this.onAcceptCounter,
    required this.onCounterOffer,
  });

  final Job job;
  final bool isBusy;
  final VoidCallback onAcceptCounter;
  final VoidCallback onCounterOffer;

  @override
  Widget build(BuildContext context) {
    final latest = job.bidHistory.last;
    final history = job.bidHistory.reversed.toList(growable: false);

    final isHomeownerCounter =
        latest.isFromHomeowner &&
        !latest.accepted &&
        job.status != JobStatus.bidAccepted &&
        !job.status.isCancelled &&
        job.status != JobStatus.completed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Bid Negotiation', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: 12),
          for (final bid in history) _bidRow(bid, bid == latest),
          if (isHomeownerCounter) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Counter',
                    onPressed: isBusy ? null : onCounterOffer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Accept',
                    onPressed: isBusy ? null : onAcceptCounter,
                    isLoading: isBusy,
                  ),
                ),
              ],
            ),
          ] else if (latest.isFromWorker &&
              !latest.accepted &&
              !job.status.isCancelled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Waiting for homeowner to respond…',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bidRow(Bid bid, bool isLatest) {
    final label = bid.isFromWorker ? 'You bid' : 'Homeowner offered';
    final h = bid.submittedAt.hour % 12 == 0 ? 12 : bid.submittedAt.hour % 12;
    final m = bid.submittedAt.minute.toString().padLeft(2, '0');
    final am = bid.submittedAt.hour < 12 ? 'AM' : 'PM';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isLatest ? AppColors.primary : AppColors.border,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label  •  PKR ${bid.amount.toStringAsFixed(0)}',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: isLatest ? FontWeight.w600 : FontWeight.w500,
                color: isLatest ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
          Text('$h:$m $am',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textMuted)),
          if (bid.accepted) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 16),
          ],
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final gross = job.finalPrice ?? 0;
    final fee = gross * AppConstants.platformFeePercent;
    final net = gross - fee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invoice', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          _row('Gross', 'PKR ${gross.toStringAsFixed(0)}'),
          _row('Platform fee (10%)', '- PKR ${fee.toStringAsFixed(0)}',
              color: AppColors.danger),
          const Divider(height: 20),
          _row('Net earnings', 'PKR ${net.toStringAsFixed(0)}',
              bold: true, color: AppColors.success),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                job.paid
                    ? Icons.check_circle_rounded
                    : Icons.hourglass_bottom_rounded,
                size: 16,
                color: job.paid ? AppColors.success : AppColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                job.paid ? 'Payment received' : 'Awaiting homeowner payment',
                style: AppTypography.bodySmall.copyWith(
                  color: job.paid ? AppColors.success : AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label, style: AppTypography.labelMedium),
      onPressed: onTap,
      backgroundColor: AppColors.primary.withValues(alpha: 0.06),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
