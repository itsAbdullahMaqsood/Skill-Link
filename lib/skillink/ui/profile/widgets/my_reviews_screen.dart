import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/review_repository.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

final _myReceivedReviewsProvider =
    FutureProvider.autoDispose<List<Review>>((ref) async {
  final repo = ref.watch(reviewRepositoryProvider);
  final res = await repo.getMyReviews(type: MyReviewsType.received);
  return res.when(
    success: (list) => list,
    failure: (msg, _) => throw Exception(msg),
  );
});

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_myReceivedReviewsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Reviews'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_myReceivedReviewsProvider),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 80),
              Center(
                child: Text(
                  'Could not load reviews.\n$e',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 80),
                  Icon(Icons.star_border_rounded,
                      size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'No reviews yet.',
                      style: AppTypography.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Reviews left by others will appear here.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              );
            }
            final sorted = [...reviews]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ReviewCard(review: sorted[i]),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Stars(rating: review.rating),
                const Spacer(),
                Text(
                  _formatDate(review.createdAt),
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.comment!.trim(),
                style: AppTypography.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final full = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < full;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: 20,
          color: filled ? AppColors.accent : AppColors.border,
        );
      }),
    );
  }
}
