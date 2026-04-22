import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/chat/chat_entry.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/secondary_button.dart';
import 'package:skilllink/skillink/ui/marketplace/view_models/worker_profile_view_model.dart';
import 'package:skilllink/skillink/utils/text_format.dart';

class WorkerProfileScreen extends ConsumerWidget {
  const WorkerProfileScreen({
    super.key,
    required this.workerId,
    this.hideBookButton = false,
  });

  final String workerId;

  final bool hideBookButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = workerProfileViewModelProvider(workerId);
    final state = ref.watch(provider);
    final serviceMap =
        ref.watch(labourServiceIdToNameProvider).valueOrNull ?? const {};
    final serviceLabels = state.worker != null
        ? resolveWorkerServiceLabels(state.worker!, idToName: serviceMap)
        : const <String>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          state.worker?.name ?? 'Profile',
          style: AppTypography.headlineMedium,
        ),
      ),
      body: _Body(
        state: state,
        onRetry: ref.read(provider.notifier).refresh,
        serviceLabels: serviceLabels,
      ),
      bottomNavigationBar: state.worker == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: hideBookButton ? 1 : 1,
                      child: SecondaryButton(
                        label: 'Message',
                        icon: Icons.chat_bubble_outline_rounded,
                        onPressed: () => ChatEntry.openWithWorker(
                          context,
                          ref,
                          worker: state.worker!,
                        ),
                      ),
                    ),
                    if (!hideBookButton) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          label: 'Book Now',
                          icon: Icons.event_available_rounded,
                          onPressed: () =>
                              context.push(Routes.booking(workerId)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.onRetry,
    required this.serviceLabels,
  });

  final WorkerProfileState state;
  final Future<void> Function() onRetry;
  final List<String> serviceLabels;

  @override
  Widget build(BuildContext context) {
    final worker = state.worker;

    if (worker == null) {
      if (state.errorMessage != null) {
        return ErrorView(message: state.errorMessage!, onRetry: onRetry);
      }
      return const _ProfileSkeleton();
    }

    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
        _Header(worker: worker, serviceLabels: serviceLabels),
        const SizedBox(height: 20),
        _InfoRow(worker: worker, serviceLabels: serviceLabels),
        if ((worker.bio ?? '').isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('About', style: AppTypography.titleLarge),
          const SizedBox(height: 6),
          Text(worker.bio!, style: AppTypography.bodyMedium),
        ],
        if (worker.portfolioUrls.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Portfolio', style: AppTypography.titleLarge),
          const SizedBox(height: 10),
          _Portfolio(urls: worker.portfolioUrls),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews', style: AppTypography.titleLarge),
            Text(
              '${worker.rating.toStringAsFixed(1)} ★ '
              '(${worker.reviewCount})',
              style: AppTypography.labelLarge
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (state.reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'No reviews yet.',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textMuted),
            ),
          )
        else
          ...state.reviews.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReviewTile(review: r),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.worker, required this.serviceLabels});

  final Worker worker;
  final List<String> serviceLabels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: worker.avatarUrl == null
                  ? CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.shimmerBase,
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: AppColors.textMuted,
                      ),
                    )
                  : ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: worker.avatarUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => LoadingShimmer(
                          width: 80,
                          height: 80,
                          borderRadius: 40,
                        ),
                        errorWidget: (context, url, error) => ColoredBox(
                          color: AppColors.shimmerBase,
                          child: const Icon(
                            Icons.person,
                            size: 32,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
            ),
            if (worker.verificationStatus)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(worker.name, style: AppTypography.headlineSmall),
              const SizedBox(height: 4),
              Text(
                serviceLabels.isEmpty
                    ? worker.primaryTrade
                    : serviceLabels.join(' · '),
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text(
                    worker.rating.toStringAsFixed(1),
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${worker.reviewCount} reviews)',
                    style: AppTypography.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.worker, required this.serviceLabels});

  final Worker worker;
  final List<String> serviceLabels;

  @override
  Widget build(BuildContext context) {
    final servicesValue = serviceLabels.isEmpty
        ? worker.primaryTrade
        : serviceLabels.join(', ');

    final roleValue = _formatWorkerRole(worker);
    final statusValue = _formatWorkerStatus(worker);
    final experienceValue = _formatWorkerExperience(worker);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.handyman_rounded,
                label: 'Services',
                value: servicesValue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoTile(
                icon: Icons.badge_outlined,
                label: 'Role',
                value: roleValue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.verified_outlined,
                label: 'Status',
                value: statusValue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoTile(
                icon: Icons.workspace_premium_outlined,
                label: 'Experience',
                value: experienceValue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _formatWorkerRole(Worker w) {
  final r = w.role?.trim();
  if (r == null || r.isEmpty) return '—';
  return TextFormat.titleCase(r.replaceAll('_', ' '));
}

String _formatWorkerStatus(Worker w) {
  final s = w.accountStatus?.trim();
  if (s == null || s.isEmpty) return '—';
  return TextFormat.titleCase(s.replaceAll('_', ' '));
}

String _formatWorkerExperience(Worker w) {
  final parts = <String>[];
  if (w.experienceYears != null) {
    parts.add(
      '${w.experienceYears} yr${w.experienceYears == 1 ? '' : 's'}',
    );
  }
  final note = w.experienceNote?.trim();
  if (note != null && note.isNotEmpty) {
    parts.add(note);
  }
  if (parts.isEmpty) return '—';
  return parts.join(' · ');
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.labelMedium),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.labelLarge,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Portfolio extends StatelessWidget {
  const _Portfolio({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: urls[i],
            width: 170,
            height: 130,
            fit: BoxFit.cover,
            placeholder: (_, _) =>
                const SizedBox(width: 170, child: LoadingShimmer(height: 130)),
            errorWidget: (_, _, _) => Container(
              width: 170,
              color: AppColors.shimmerBase,
              child: const Icon(Icons.broken_image_outlined,
                  color: AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.reviewerName ?? 'Anonymous',
                  style: AppTypography.labelLarge,
                ),
              ),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= review.rating.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14,
                      color: AppColors.accent,
                    ),
                ],
              ),
            ],
          ),
          if ((review.comment ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.comment!, style: AppTypography.bodyMedium),
          ],
          const SizedBox(height: 6),
          Text(
            _relativeTime(review.createdAt),
            style: AppTypography.labelMedium,
          ),
        ],
      ),
    );
  }

  static String _relativeTime(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()} mo ago';
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()} wk ago';
    if (diff.inDays >= 1) return '${diff.inDays} d ago';
    if (diff.inHours >= 1) return '${diff.inHours} h ago';
    return 'just now';
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: const [
        Row(
          children: [
            LoadingShimmer(width: 80, height: 80, borderRadius: 40),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingShimmer(width: 180),
                  SizedBox(height: 8),
                  LoadingShimmer(width: 120),
                  SizedBox(height: 8),
                  LoadingShimmer(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        LoadingShimmer(height: 80),
        SizedBox(height: 20),
        LoadingShimmer(height: 130),
      ],
    );
  }
}
