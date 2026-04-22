import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/job_post_tag.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/open_jobs/view_models/open_jobs_view_model.dart';
import 'package:skilllink/skillink/ui/open_jobs/widgets/bid_sheet.dart';
import 'package:skilllink/skillink/utils/text_format.dart';
import 'package:skilllink/skillink/utils/trade_icon.dart';

const _kInlineOpenJobsCap = 8;

class OpenJobsSection extends ConsumerWidget {
  const OpenJobsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(openJobsViewModelProvider);
    if (st.isLoading) {
      return const LoadingShimmerList();
    }
    if (st.errorMessage != null) {
      return Text(st.errorMessage!, style: AppTypography.bodySmall);
    }
    if (st.rows.isEmpty) {
      return const EmptyState(
        icon: Icons.work_outline_rounded,
        title: 'No open jobs',
        subtitle: 'Jobs matching your skills will appear here.',
      );
    }
    final visible = st.rows.take(_kInlineOpenJobsCap).toList();
    final hiddenCount = st.rows.length - visible.length;
    return Column(
      children: [
        for (final r in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.push(Routes.postedJobDetail(r.job.jobId)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            TradeIcon.forTrade(r.job.tag.serviceTypeSlug),
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              r.job.title,
                              style: AppTypography.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${r.job.homeownerDisplayName ?? 'Homeowner'} · '
                        '${r.distanceKm.toStringAsFixed(1)} km · '
                        '${r.bidCount} bids',
                        style: AppTypography.bodySmall,
                      ),
                      Text(
                        TextFormat.trade(r.job.tag.serviceTypeSlug),
                        style: AppTypography.labelMedium,
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Bid now',
                        icon: Icons.gavel_rounded,
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (_) => BidSheet(job: r.job),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (hiddenCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Text(
              'Showing $_kInlineOpenJobsCap of ${st.rows.length} open jobs · pull to refresh.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ),
      ],
    );
  }
}
