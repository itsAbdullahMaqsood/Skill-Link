import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/models/user.dart';
import 'package:skilllink/Pages/my_posts/my_posts_screen.dart';
import 'package:skilllink/Pages/ongoing/ongoing_screen.dart';
import 'package:skilllink/Pages/timecoin/timecoin_screen.dart';
import 'package:skilllink/Pages/settings/settings_screen.dart';
import 'package:skilllink/router/app_router.dart' as app_router;
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/Widgets/user_avatar.dart';

class HomeDrawer extends ConsumerWidget {
  final UserModel user;
  final int timecoinBalance;
  final void Function(int index) onSelectTab;
  final void Function(Widget screen) onPushScreen;
  final VoidCallback onLogout;

  const HomeDrawer({
    super.key,
    required this.user,
    required this.timecoinBalance,
    required this.onSelectTab,
    required this.onPushScreen,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          onSelectTab(4);
                        },
                        borderRadius: BorderRadius.circular(35),
                        child: Semantics(
                          label: 'Open profile',
                          button: true,
                          child: UserAvatar(
                            imageRef: user.profilePic,
                            radius: 35,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.fullName,
                                    style: AppTypography.headlineMedium
                                        .copyWith(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (user.verified)
                                  const Icon(
                                    Icons.verified,
                                    color: AppColors.accentLight,
                                    size: 20,
                                    semanticLabel: 'Verified',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: SvgPicture.asset(
                                      'assets/images/timecoin.svg',
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.contain,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$timecoinBalance',
                                    style: AppTypography.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              color: AppColors.background,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    icon: Icons.article_outlined,
                    value: '${user.posts ?? user.myOffers.length}',
                    label: 'Active Posts',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.border,
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.star_outline,
                    value: user.ratings.toStringAsFixed(1),
                    label: 'Rating',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.border,
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.rate_review_outlined,
                    value: '${user.reviewsCount}',
                    label: 'Reviews',
                  ),
                ],
              ),
            ),

            _buildDrawerItem(
              context,
              icon: Icons.home_outlined,
              title: 'Home',
              onTap: () {
                Navigator.pop(context);
                onSelectTab(0);
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.article_outlined,
              title: 'My Posts',
              onTap: () {
                Navigator.pop(context);
                onPushScreen(const MyPostsScreen());
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.monetization_on_outlined,
              title: 'Timecoins',
              onTap: () {
                Navigator.pop(context);
                onPushScreen(const TimecoinScreen());
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Messages',
              onTap: () {
                Navigator.pop(context);
                onSelectTab(1);
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.handshake_outlined,
              title: 'Ongoing',
              onTap: () {
                Navigator.pop(context);
                onPushScreen(const OngoingScreen());
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              badge: '3',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications feature coming soon!'),
                  ),
                );
              },
            ),

            const Divider(height: 1),

            _buildDrawerItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                onPushScreen(const SettingsScreen());
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help & Support feature coming soon!'),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About Skill Link'),
                    content: const Text(
                      'Skill Link v1.0.0\n\n'
                      'Connect, learn, and exchange skills with a global community.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(height: 1),

            _buildDrawerItem(
              context,
              icon: Icons.swap_horiz,
              title: 'Switch skill type',
              onTap: () async {
                final container =
                    ProviderScope.containerOf(context, listen: false);
                Navigator.pop(context);
                await AuthService().logout();
                await app_router.reloadSkillPrefs(container);
                if (!context.mounted) return;
                context.go(app_router.skillTypePath);
              },
            ),

            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              textColor: AppColors.danger,
              iconColor: AppColors.danger,
              onTap: () {
                Navigator.pop(context);
                onLogout();
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

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? badge,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
      onTap: onTap,
      minLeadingWidth: 0,
      horizontalTitleGap: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
