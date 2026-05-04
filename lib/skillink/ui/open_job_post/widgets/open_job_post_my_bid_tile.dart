import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/domain/models/open_job_post_bid.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/open_job_post_card.dart';
import 'package:skilllink/skillink/utils/currency_format.dart';

/// Card for an open job post where the current user has bid: loads bids and
/// shows this worker's amount (same behaviour as My Bids screen).
class OpenJobPostMyBidTile extends ConsumerWidget {
  const OpenJobPostMyBidTile({super.key, required this.post});

  final OpenJobPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidsAsync = ref.watch(openJobPostBidsProvider(post.id));
    final uid = ref.watch(authViewModelProvider).user?.id;

    final bid = bidsAsync.maybeWhen(
      data: (list) {
        if (list.isEmpty || uid == null || uid.isEmpty) return null;
        for (final b in list) {
          if (b.workerId == uid) return b;
        }
        return null;
      },
      orElse: () => null,
    );

    return OpenJobPostCard(
      post: post,
      onTap: () => context.push(Routes.openJobPostDetail(post.id)),
      trailing: bidsAsync.maybeWhen(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (err, _) => Tooltip(
          message: 'Could not load your bid.',
          child: Icon(Icons.help_outline_rounded, size: 20, color: AppColors.textMuted),
        ),
        orElse: () => bid != null ? OpenJobPostBidAmountBadge(bid: bid) : null,
      ),
    );
  }
}

class OpenJobPostBidAmountBadge extends StatelessWidget {
  const OpenJobPostBidAmountBadge({super.key, required this.bid});

  final OpenJobPostBid bid;

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
      _ => (
          AppColors.primary.withValues(alpha: 0.12),
          AppColors.primary,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        formatPkr(bid.amount + bid.visitingFee),
        style: AppTypography.labelMedium
            .copyWith(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
