import 'package:flutter/material.dart';
import 'package:skilllink/skillink/domain/models/bid.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/secondary_button.dart';

class BidCard extends StatelessWidget {
  const BidCard({
    super.key,
    required this.job,
    required this.onAccept,
    required this.onCounter,
    this.isBusy = false,
  });

  final Job job;
  final VoidCallback onAccept;
  final VoidCallback onCounter;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    if (job.bidHistory.isEmpty) return const SizedBox.shrink();

    final latest = job.bidHistory.last;
    final history =
        job.bidHistory.reversed.toList(growable: false);
    final isAcceptable =
        latest.isFromWorker &&
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
              Text(
                'Bid negotiation',
                style: AppTypography.titleLarge
                    .copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final bid in history) _BidRow(bid: bid, isLatest: bid == latest),
          if (isAcceptable) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Counter',
                    onPressed: isBusy ? null : onCounter,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Accept',
                    onPressed: isBusy ? null : onAccept,
                    isLoading: isBusy,
                  ),
                ),
              ],
            ),
          ] else if (latest.isFromHomeowner &&
              !latest.accepted &&
              !job.status.isCancelled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Waiting for the worker to respond to your counter…',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _BidRow extends StatelessWidget {
  const _BidRow({required this.bid, required this.isLatest});

  final Bid bid;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    final label = bid.isFromHomeowner ? 'You offered' : 'Worker bid';
    final amount = 'PKR ${bid.amount.toStringAsFixed(0)}';
    final time = _timeFormat(bid.submittedAt);

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
              '$label  •  $amount',
              style: AppTypography.bodyMedium.copyWith(
                color: isLatest ? AppColors.textPrimary : AppColors.textMuted,
                fontWeight: isLatest ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textMuted),
          ),
          if (bid.accepted) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 16),
          ],
        ],
      ),
    );
  }

  String _timeFormat(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final am = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $am';
  }
}
