import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/open_job_post_card.dart';
import 'package:skilllink/skillink/utils/error_mapper.dart';

class MyPostsScreen extends ConsumerWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(myOpenJobPostsProvider(ServiceRequestRole.customer));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text('My Posts', style: AppTypography.headlineMedium),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Open'),
              Tab(text: 'Selected'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(
            myOpenJobPostsProvider(ServiceRequestRole.customer).future,
          ),
          child: async.when(
            data: (posts) => TabBarView(
              children: [
                _PostedList(
                  posts: posts
                      .where((p) => p.status == OpenJobPostStatus.openForBids)
                      .toList(),
                ),
                _PostedList(
                  posts: posts
                      .where((p) =>
                          p.status == OpenJobPostStatus.workerSelected ||
                          p.status == OpenJobPostStatus.awarded ||
                          p.status == OpenJobPostStatus.closed)
                      .toList(),
                ),
                _PostedList(
                  posts: posts
                      .where((p) => p.status == OpenJobPostStatus.cancelled)
                      .toList(),
                ),
              ],
            ),
            loading: () => const LoadingShimmerList(),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  ErrorMapper.fromException(e),
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostedList extends StatelessWidget {
  const _PostedList({required this.posts});

  final List<OpenJobPost> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          EmptyState(
            icon: Icons.post_add_outlined,
            title: 'Nothing here',
            subtitle: 'Posts in this tab will show up here.',
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
        final p = posts[i];
        return OpenJobPostCard(
          post: p,
          onTap: () => context.push(Routes.openJobPostDetail(p.id)),
          trailing: (p.bidCount != null &&
                  p.status == OpenJobPostStatus.openForBids)
              ? _BidCountBadge(count: p.bidCount!)
              : null,
        );
      },
    );
  }
}

class _BidCountBadge extends StatelessWidget {
  const _BidCountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count bid${count == 1 ? '' : 's'}',
        style: AppTypography.labelMedium
            .copyWith(color: AppColors.primary, fontSize: 11),
      ),
    );
  }
}
