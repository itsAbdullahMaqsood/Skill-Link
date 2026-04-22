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

class DiscoverOpenJobsScreen extends ConsumerWidget {
  const DiscoverOpenJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(discoverOpenJobPostsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Open Jobs', style: AppTypography.headlineMedium),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(discoverOpenJobPostsProvider.future),
        child: async.when(
          data: (posts) {
            if (posts.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  EmptyState(
                    icon: Icons.work_outline_rounded,
                    title: 'No open jobs right now',
                    subtitle:
                        'New posts matching your skills will appear here. '
                        'Pull to refresh.',
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final post = posts[i];
                return OpenJobPostCard(
                  post: post,
                  onTap: () =>
                      context.push(Routes.openJobPostDetail(post.id)),
                  onSubmitBid: () async {
                    final ok =
                        await OpenJobPostBidSheet.show(context, post: post);
                    if (!context.mounted) return;
                    if (ok == true) {
                      ref.invalidate(discoverOpenJobPostsProvider);
                    }
                  },
                );
              },
            );
          },
          loading: () => const LoadingShimmerList(),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                'Could not load open jobs',
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '$e',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
