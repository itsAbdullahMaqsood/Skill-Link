import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/models/user.dart' as sc;
import 'package:skilllink/router/app_router.dart' as app_router;
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_scaffold.dart';
import 'package:skilllink/skillink/ui/profile/view_models/profile_view_model.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(authViewModelProvider).user;
    final labourAsync = ref.watch(currentLabourUserProvider);
    final vm = ref.read(profileViewModelProvider.notifier);
    final ui = ref.watch(profileViewModelProvider);

    ref.listen(profileViewModelProvider.select((s) => s.errorMessage),
        (prev, msg) {
      if (msg == null || msg == prev) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
      vm.clearError();
    });

    ref.listen(profileViewModelProvider.select((s) => s.saveSuccess),
        (prev, ok) {
      if (ok == true && prev != true) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Profile saved'),
              backgroundColor: AppColors.success,
            ),
          );
        vm.clearSaveSuccess();
      }
    });

    ref.listen(
      profileViewModelProvider.select((s) => s.avatarSuccessCount),
      (prev, count) {
        if (prev != null && count > prev) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Profile photo updated'),
                backgroundColor: AppColors.success,
              ),
            );
        }
      },
    );

    if (appUser == null) {
      return AppScaffold(
        title: 'Profile',
        body: const Center(child: Text('Not signed in.')),
      );
    }

    final labour = labourAsync.valueOrNull;
    final avatar = labour?.profileImageUrl.isNotEmpty == true
        ? labour!.profileImageUrl
        : appUser.avatarUrl;
    final name = (labour?.fullName.isNotEmpty == true
            ? labour!.fullName
            : appUser.name)
        .trim();
    final email = (labour?.email.isNotEmpty == true
            ? labour!.email
            : appUser.email)
        .trim();
    final phone = (labour?.phoneNumber.isNotEmpty == true
            ? labour!.phoneNumber
            : appUser.phone)
        .trim();
    final location = _resolveLocation(labour, appUser.address.city);

    return AppScaffold(
      title: 'Account',
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authViewModelProvider.notifier).reloadSession();
          ref.invalidate(currentLabourUserProvider);
          await ref.read(currentLabourUserProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SizedBox(height: 8),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.border,
                    child: ui.uploadingAvatar
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : (avatar != null && avatar.isNotEmpty)
                            ? ClipOval(
                                child:
                                    accountAvatarSquare(avatar, size: 96),
                              )
                            : const Icon(
                                Icons.person,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                  ),
                  if (!ui.uploadingAvatar)
                    Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => vm.pickAndUploadAvatar(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name.isEmpty ? email : name,
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            if (email.isNotEmpty)
              Text(
                email,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 10),
            _StatusRow(labour: labour),
            if (labour?.bio != null && labour!.bio!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  labour.bio!.trim(),
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 18),

            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  if (phone.isNotEmpty)
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: phone,
                    ),
                  if (location.isNotEmpty) ...[
                    if (phone.isNotEmpty) const Divider(height: 1),
                    _InfoTile(
                      icon: Icons.place_outlined,
                      label: 'Location',
                      value: location,
                    ),
                  ],
                  if (labour != null && labour.age > 0) ...[
                    const Divider(height: 1),
                    _InfoTile(
                      icon: Icons.cake_outlined,
                      label: 'Age',
                      value: '${labour.age}',
                    ),
                  ],
                  if (labour != null && labour.gender.trim().isNotEmpty) ...[
                    const Divider(height: 1),
                    _InfoTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Gender',
                      value: _capitalize(labour.gender.trim()),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Edit profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(Routes.profileEdit),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Change password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password changes will be available in a future update.',
                          ),
                        ),
                      );
                    },
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
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(Routes.notifications),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: Text(
                'Log out',
                style: AppTypography.titleLarge
                    .copyWith(color: AppColors.danger),
              ),
              onTap: () => _confirmLogout(context, ref),
            ),
            const SizedBox(height: 8),
            Text(
              'Support: ${AppConstants.supportEmail}',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _resolveLocation(sc.UserModel? labour, String fallbackCity) {
    final loc = (labour?.location ?? '').trim();
    if (loc.isNotEmpty) return loc;
    return fallbackCity.trim();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to use SkillLink.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (go != true || !context.mounted) return;
    final container = ProviderScope.containerOf(context, listen: false);
    await ref.read(authViewModelProvider.notifier).signOut();
    await app_router.reloadSkillPrefs(container);
    if (context.mounted) context.go(app_router.skillTypePath);
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.labour});

  final sc.UserModel? labour;

  @override
  Widget build(BuildContext context) {
    final role = (labour?.labourApiRole ?? '').trim();
    final status = (labour?.status ?? '').trim();
    final verified = labour?.verified ?? false;

    final chips = <Widget>[];
    if (role.isNotEmpty) {
      chips.add(_Pill(
        label: _roleLabel(role),
        background: AppColors.primary.withValues(alpha: 0.08),
        foreground: AppColors.primary,
        icon: labour!.isLabourWorkerRole
            ? Icons.construction_rounded
            : Icons.home_rounded,
      ));
    }
    if (status.isNotEmpty) {
      final approved = status.toLowerCase() == 'approved';
      chips.add(_Pill(
        label: _capitalizeFirst(status),
        background: (approved ? AppColors.success : AppColors.warning)
            .withValues(alpha: 0.10),
        foreground: approved ? AppColors.success : AppColors.warning,
        icon: approved
            ? Icons.check_circle_outline_rounded
            : Icons.hourglass_top_rounded,
      ));
    }
    if (verified) {
      chips.add(const _Pill(
        label: 'Verified',
        background: Color(0x1A2E7D32),
        foreground: AppColors.success,
        icon: Icons.verified_rounded,
      ));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: chips,
    );
  }

  String _roleLabel(String apiRole) {
    switch (apiRole.toLowerCase()) {
      case 'worker':
      case 'provider':
      case 'labour':
      case 'service_provider':
        return 'Worker';
      case 'user':
      case 'homeowner':
      case 'client':
      case 'customer':
        return 'Homeowner';
      default:
        return _capitalizeFirst(apiRole);
    }
  }

  String _capitalizeFirst(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
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
    return ListTile(
      leading: Icon(icon, color: AppColors.textMuted),
      title: Text(
        label,
        style:
            AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      ),
      subtitle: Text(value, style: AppTypography.bodyMedium),
      dense: true,
    );
  }
}
