import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/router/app_router.dart' as app_router;
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/worker_home/view_models/worker_jobs_view_model.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider);
    final user = auth.user;
    final role = user?.role ?? UserRole.homeowner;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                ),
              ),
              padding: const EdgeInsets.only(
                top: 56,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(
                        role == UserRole.worker
                            ? Routes.workerMyProfile
                            : Routes.profile,
                      );
                    },
                    borderRadius: BorderRadius.circular(35),
                    child: Semantics(
                      label: 'Open profile',
                      button: true,
                      child: RoundAvatar(
                        url: user?.avatarUrl,
                        radius: 35,
                        backgroundColor: Colors.white,
                        placeholder: const Icon(
                          Icons.person,
                          size: 34,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest',
                          style: AppTypography.headlineMedium
                              .copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 10),
                        _RolePill(
                          label: role == UserRole.worker
                              ? 'Skilled Worker'
                              : 'Homeowner',
                          icon: role == UserRole.worker
                              ? Icons.handyman_rounded
                              : Icons.home_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _QuickStats(role: role),

            if (role == UserRole.homeowner)
              ..._homeownerItems(context)
            else
              ..._workerItems(context, ref),

            const Divider(height: 1),

            _DrawerItem(
              icon: Icons.swap_horiz,
              label: 'Switch skill type',
              onTap: () async {
                final container =
                    ProviderScope.containerOf(context, listen: false);
                Navigator.of(context).pop();
                await ref.read(authViewModelProvider.notifier).signOut();
                await app_router.reloadSkillPrefs(container);
                if (!context.mounted) return;
                context.go(app_router.skillTypePath);
              },
            ),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Logout',
              textColor: AppColors.danger,
              iconColor: AppColors.danger,
              onTap: () async {
                final container =
                    ProviderScope.containerOf(context, listen: false);
                Navigator.of(context).pop();
                await ref.read(authViewModelProvider.notifier).signOut();
                await app_router.reloadSkillPrefs(container);
                if (!context.mounted) return;
                context.go(app_router.skillTypePath);
              },
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Text(
                'Skill Link © 2024',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _homeownerItems(BuildContext context) {
    return [
      _DrawerItem(
        icon: Icons.home_outlined,
        label: 'Home',
        onTap: () {
          Navigator.of(context).pop();
          context.go(Routes.homeownerHome);
        },
      ),
      _DrawerItem(
        icon: Icons.post_add_rounded,
        label: 'My Posts',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.myPosts);
        },
      ),
      _DrawerItem(
        icon: Icons.outbox_outlined,
        label: 'Sent Requests',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.sentRequests);
        },
      ),
      _DrawerItem(
        icon: Icons.chat_bubble_outline,
        label: 'Chat',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.chatList);
        },
      ),
      _DrawerItem(
        icon: Icons.sensors_rounded,
        label: 'IoT Devices',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.iotDevices);
        },
      ),
      _DrawerItem(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.notifications);
        },
      ),
      const Divider(height: 1),
      _DrawerItem(
        icon: Icons.settings_outlined,
        label: 'Settings',
        onTap: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                const SnackBar(content: Text('Settings coming soon')));
        },
      ),
      _DrawerItem(
        icon: Icons.help_outline,
        label: 'Help & Support',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.helpSupport);
        },
      ),
      _DrawerItem(
        icon: Icons.info_outline,
        label: 'About',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.about);
        },
      ),
    ];
  }

  List<Widget> _workerItems(BuildContext context, WidgetRef ref) {
    return [
      _DrawerItem(
        icon: Icons.home_outlined,
        label: 'Home',
        onTap: () {
          Navigator.of(context).pop();
          context.go(Routes.workerJobs);
        },
      ),
      _DrawerItem(
        icon: Icons.handshake_outlined,
        label: 'Ongoing Jobs',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.workerOngoing);
        },
      ),
      _DrawerItem(
        icon: Icons.inbox_outlined,
        label: 'Direct Bookings',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.receivedRequests);
        },
      ),
      _DrawerItem(
        icon: Icons.gavel_rounded,
        label: 'My Bids',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.myBids);
        },
      ),
      _DrawerItem(
        icon: Icons.chat_bubble_outline,
        label: 'Chat',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.chatList);
        },
      ),
      _DrawerItem(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Earnings',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.workerEarnings);
        },
      ),
      const Divider(height: 1),
      _DrawerItem(
        icon: Icons.settings_outlined,
        label: 'Settings',
        onTap: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                const SnackBar(content: Text('Settings coming soon')));
        },
      ),
      _DrawerItem(
        icon: Icons.help_outline,
        label: 'Help & Support',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.helpSupport);
        },
      ),
      _DrawerItem(
        icon: Icons.info_outline,
        label: 'About',
        onTap: () {
          Navigator.of(context).pop();
          context.push(Routes.about);
        },
      ),
    ];
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends ConsumerWidget {
  const _QuickStats({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (primaryValue, primaryLabel, primaryIcon) = role == UserRole.worker
        ? _workerPrimary(ref)
        : (const _StatPair('—', 'Active Posts'), Icons.article_outlined).asTriple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: primaryIcon,
            value: primaryValue,
            label: primaryLabel,
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          const _StatItem(
            icon: Icons.star_outline,
            value: '—',
            label: 'Rating',
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatItem(
            icon: role == UserRole.worker
                ? Icons.check_circle_outline
                : Icons.rate_review_outlined,
            value: '—',
            label: role == UserRole.worker ? 'Completed' : 'Reviews',
          ),
        ],
      ),
    );
  }

  (String, String, IconData) _workerPrimary(WidgetRef ref) {
    final state = ref.watch(workerJobsViewModelProvider);
    final ongoing = state.activeJob == null ? 0 : 1;
    return ('$ongoing', 'Ongoing', Icons.handshake_outlined);
  }
}

class _StatPair {
  const _StatPair(this.value, this.label);
  final String value;
  final String label;
}

extension on (_StatPair, IconData) {
  (String, String, IconData) get asTriple => ($1.value, $1.label, $2);
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.titleLarge
              .copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Widget tail = trailing ??
        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
          size: 20,
        );

    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: tail,
      onTap: onTap,
      minLeadingWidth: 0,
      horizontalTitleGap: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
