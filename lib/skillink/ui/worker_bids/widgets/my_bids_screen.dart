import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/open_job_post_my_bid_tile.dart';
import 'package:skilllink/skillink/utils/error_mapper.dart';

class MyBidsScreen extends ConsumerWidget {
  const MyBidsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(myOpenJobPostsProvider(ServiceRequestRole.worker));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text('My Bids', style: AppTypography.headlineMedium),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Won'),
              Tab(text: 'Closed'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(
            myOpenJobPostsProvider(ServiceRequestRole.worker).future,
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
                          (p.status == OpenJobPostStatus.workerSelected ||
                              p.status == OpenJobPostStatus.awarded))
                      .toList(),
                ),
                _PostedList(
                  posts: posts
                      .where((p) =>
                          p.status == OpenJobPostStatus.cancelled ||
                          p.status == OpenJobPostStatus.closed)
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
            icon: Icons.gavel_outlined,
            title: 'Nothing here',
            subtitle: 'Your bids in this tab will show up here.',
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (_, i) => OpenJobPostMyBidTile(post: posts[i]),
    );
  }
}
