import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/open_job_post_bid_sheet.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/open_job_post_card.dart';

const _kInlineCap = 5;

class DiscoverOpenJobsSection extends ConsumerWidget {
  const DiscoverOpenJobsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(discoverOpenJobPostsProvider);
    return async.when(
      loading: () => const LoadingShimmerList(),
      error: (e, _) => Text(
        '$e',
        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return const EmptyState(
            icon: Icons.work_outline_rounded,
            title: 'No open jobs right now',
            subtitle: 'Posts matching your skills will appear here.',
          );
        }
        final visible = posts.take(_kInlineCap).toList();
        final hiddenCount = posts.length - visible.length;
        return Column(
          children: [
            for (final p in visible)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OpenJobPostCard(
                  post: p,
                  onTap: () =>
                      context.push(Routes.openJobPostDetail(p.id)),
                  onSubmitBid: () async {
                    final ok = await OpenJobPostBidSheet.show(context, post: p);
                    if (!context.mounted) return;
                    if (ok == true) {
                      ref.invalidate(discoverOpenJobPostsProvider);
                    }
                  },
                ),
              ),
            if (hiddenCount > 0)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () =>
                      context.push(Routes.discoverOpenJobs),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(
                    'See all ($hiddenCount more)',
                    style: AppTypography.labelMedium,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
