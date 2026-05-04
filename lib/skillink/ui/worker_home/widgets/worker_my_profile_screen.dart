import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/models/user.dart' as sc;
import 'package:skilllink/router/app_router.dart' as app_router;
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/worker_home/view_models/worker_profile_view_model.dart';
import 'package:skilllink/skillink/ui/worker_home/widgets/worker_profile_shared.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';

String _capitalizeWord(String s) {
  final t = s.trim();
  if (t.isEmpty) return '';
  return t[0].toUpperCase() + t.substring(1).toLowerCase();
}

class WorkerMyProfileScreen extends ConsumerWidget {
  const WorkerMyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workerProfileViewModelProvider);
    final vm = ref.read(workerProfileViewModelProvider.notifier);
    final serviceMap =
        ref.watch(labourServiceIdToNameProvider).valueOrNull ?? const {};
    final labour = ref.watch(currentLabourUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('My Profile', style: AppTypography.headlineMedium),
      ),
      body: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingShimmer(height: 300),
            )
          : state.worker == null
          ? const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Profile unavailable',
              subtitle: 'Could not load your profile.',
            )
          : RefreshIndicator(
              onRefresh: vm.refresh,
              child: _ProfileBody(
                state: state,
                serviceMap: serviceMap,
                labour: labour,
              ),
            ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({
    required this.state,
    required this.serviceMap,
    required this.labour,
  });

  final WorkerProfileState state;
  final Map<String, String> serviceMap;
  final sc.UserModel? labour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = state.worker!;
    final serviceLabels = resolveWorkerServiceLabels(w, idToName: serviceMap);
    final email = (labour?.email ?? w.email).trim();
    final location = (labour?.location ?? w.location ?? '').trim();
    final age = labour?.age ?? 0;
    final gender = (labour?.gender ?? '').trim();
    final bio = (labour?.bio ?? w.bio ?? '').trim();
    final pastExp = (labour?.pastExperience ?? '').trim();
    final labourUser = labour;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (w.rating < AppConstants.lowRatingWarningThreshold &&
            w.reviewCount > 0)
          WorkerProfileWarningBanner(rating: w.rating),
        Center(
          child: RoundAvatar(
            url: w.avatarUrl,
            pickedFile: null,
            radius: 44,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            placeholder: const Icon(
              Icons.person_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 18, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(
                '${w.rating.toStringAsFixed(1)}  (${w.reviewCount} reviews)',
                style: AppTypography.bodyMedium,
              ),
              if (w.verificationStatus) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
        Center(
          child: TextButton.icon(
            onPressed: () => context.push(Routes.myReviews),
            icon: const Icon(Icons.reviews_outlined, size: 18),
            label: const Text('View all reviews'),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Wrap(
            spacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final label in serviceLabels)
                Chip(
                  label: Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  side: BorderSide.none,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        WorkerAccountStatusRow(labour: labour),
        const SizedBox(height: 20),
        Text('Your details', style: AppTypography.titleLarge),
        const SizedBox(height: 8),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              WorkerProfileInfoTile(
                icon: Icons.badge_outlined,
                label: 'Full name',
                value: w.name.trim().isEmpty ? '—' : w.name.trim(),
              ),
              const Divider(height: 1),
              WorkerProfileInfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: w.phone.trim().isEmpty ? '—' : w.phone.trim(),
              ),
              if (email.isNotEmpty) ...[
                const Divider(height: 1),
                WorkerProfileInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: email,
                ),
              ],
              if (location.isNotEmpty) ...[
                const Divider(height: 1),
                WorkerProfileInfoTile(
                  icon: Icons.place_outlined,
                  label: 'Location',
                  value: location,
                ),
              ],
              if (age > 0) ...[
                const Divider(height: 1),
                WorkerProfileInfoTile(
                  icon: Icons.cake_outlined,
                  label: 'Age',
                  value: '$age',
                ),
              ],
              if (gender.isNotEmpty) ...[
                const Divider(height: 1),
                WorkerProfileInfoTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Gender',
                  value: _capitalizeWord(gender),
                ),
              ],
              if (w.hourlyRate != null) ...[
                const Divider(height: 1),
                WorkerProfileInfoTile(
                  icon: Icons.payments_outlined,
                  label: 'Hourly rate',
                  value: '${w.hourlyRate!.toStringAsFixed(0)} / hr',
                ),
              ],
              if (w.experienceYears != null && w.experienceYears! > 0) ...[
                const Divider(height: 1),
                WorkerProfileInfoTile(
                  icon: Icons.work_outline_rounded,
                  label: 'Experience (years)',
                  value: '${w.experienceYears}',
                ),
              ],
              if (w.serviceRadiusKm != null) ...[
                const Divider(height: 1),
                WorkerProfileInfoTile(
                  icon: Icons.radar_outlined,
                  label: 'Service radius',
                  value: '${w.serviceRadiusKm!.toStringAsFixed(0)} km',
                ),
              ],
            ],
          ),
        ),
        if (pastExp.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ProfileSectionCard(
            title: 'Past experience',
            icon: Icons.history_edu_outlined,
            body: pastExp,
          ),
        ],

        if (labourUser != null &&
            (labourUser.cnicFrontUrl.isNotEmpty ||
                labourUser.cnicBackUrl.isNotEmpty)) ...[
          const SizedBox(height: 16),
          Text('CNIC on file', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (labourUser.cnicFrontUrl.isNotEmpty)
                Expanded(
                  child: _WorkerCnicPreview(
                    label: 'Front',
                    imageUrl: labourUser.cnicFrontUrl,
                  ),
                ),
              if (labourUser.cnicFrontUrl.isNotEmpty &&
                  labourUser.cnicBackUrl.isNotEmpty)
                const SizedBox(width: 12),
              if (labourUser.cnicBackUrl.isNotEmpty)
                Expanded(
                  child: _WorkerCnicPreview(
                    label: 'Back',
                    imageUrl: labourUser.cnicBackUrl,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Edit profile',
          onPressed: () => context.push(Routes.workerMyProfileEdit),
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.notifications),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.helpSupport),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.danger),
                title: Text(
                  'Log out',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.danger,
                  ),
                ),
                onTap: () => _logout(context, ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Reviews received', style: AppTypography.titleLarge),
        const SizedBox(height: 10),
        if (state.reviews.isEmpty)
          const EmptyState(
            icon: Icons.rate_review_outlined,
            title: 'No reviews yet',
            subtitle: 'Reviews from homeowners will appear here.',
          )
        else
          for (final r in state.reviews) ...[
            WorkerProfileReviewTile(review: r),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await ref.read(authViewModelProvider.notifier).signOut();
    await app_router.reloadSkillPrefs(container);
    if (!context.mounted) return;
    context.go(app_router.skillTypePath);
  }
}

class _WorkerCnicPreview extends StatelessWidget {
  const _WorkerCnicPreview({required this.label, required this.imageUrl});

  final String label;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Material(
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => Dialog(
                  backgroundColor: Colors.black,
                  insetPadding: const EdgeInsets.all(12),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textMuted,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.title,
    required this.icon,
    required this.body,
  });

  final String title;
  final IconData icon;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(body, style: AppTypography.bodyMedium.copyWith(height: 1.45)),
          ],
        ),
      ),
    );
  }
}
