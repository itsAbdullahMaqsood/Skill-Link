import 'package:flutter/material.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';

class OpenJobPostCard extends StatelessWidget {
  const OpenJobPostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onSubmitBid,
    this.trailing,
  });

  final OpenJobPost post;
  final VoidCallback onTap;

  /// When set and the post is open for bids, shows a full-width submit bid button
  /// below the header row (gestures do not trigger [onTap]).
  final VoidCallback? onSubmitBid;

  final Widget? trailing;

  bool get _showSubmitBid =>
      onSubmitBid != null && post.status == OpenJobPostStatus.openForBids;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: _showSubmitBid
                ? const BorderRadius.vertical(top: Radius.circular(14))
                : BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.work_outline_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.description.trim().isEmpty
                              ? 'Open Job Post'
                              : post.description,
                          style:
                              AppTypography.titleLarge.copyWith(fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _summaryLine(post),
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        _StatusPill(status: post.status),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
          if (_showSubmitBid) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: PrimaryButton(
                label: 'Submit bid',
                icon: Icons.gavel_rounded,
                onPressed: onSubmitBid,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _summaryLine(OpenJobPost post) {
    final parts = <String>[
      if (post.scheduledServiceDate.isNotEmpty) post.scheduledServiceDate,
      '${post.timeSlot.startTime}–${post.timeSlot.endTime}',
      if (post.serviceAddress.trim().isNotEmpty)
        _truncate(post.serviceAddress, 32),
    ];
    return parts.join(' · ');
  }

  static String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max - 1)}…';
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final OpenJobPostStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      OpenJobPostStatus.openForBids => (
          AppColors.primary.withValues(alpha: 0.12),
          AppColors.primary,
        ),
      OpenJobPostStatus.workerSelected ||
      OpenJobPostStatus.awarded =>
        (
          AppColors.success.withValues(alpha: 0.14),
          AppColors.success,
        ),
      OpenJobPostStatus.cancelled =>
        (AppColors.danger.withValues(alpha: 0.12), AppColors.danger),
      OpenJobPostStatus.closed ||
      OpenJobPostStatus.unknown =>
        (
          AppColors.border.withValues(alpha: 0.4),
          AppColors.textMuted,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.displayLabel,
        style:
            AppTypography.labelMedium.copyWith(color: fg, fontSize: 11),
      ),
    );
  }
}
