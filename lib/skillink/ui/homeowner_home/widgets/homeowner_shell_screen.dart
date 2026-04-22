import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/ui/app_drawer.dart';
import 'package:skilllink/skillink/ui/core/ui/shell_back_scope.dart';

class HomeownerShellScreen extends StatelessWidget {
  const HomeownerShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _postTabIndex = 2;

  void _onTap(BuildContext context, int index) {
    if (index == _postTabIndex) {
      context.push(Routes.newOpenJobPost);
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  static const _homeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ShellBackScope(
      navigationShell: navigationShell,
      homeBranchIndex: _homeTabIndex,
      child: Scaffold(
        drawer: const AppDrawer(),
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                offset: const Offset(0, -4),
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _NavIcon(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    tooltip: 'Home',
                    isActive: navigationShell.currentIndex == 0,
                    onTap: () => _onTap(context, 0),
                  ),
                  _NavIcon(
                    icon: Icons.storefront_outlined,
                    activeIcon: Icons.storefront_rounded,
                    tooltip: 'Marketplace',
                    isActive: navigationShell.currentIndex == 1,
                    onTap: () => _onTap(context, 1),
                  ),
                  Expanded(
                    child: Center(
                      child: Material(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(14),
                        clipBehavior: Clip.antiAlias,
                        elevation: 0,
                        shadowColor: AppColors.accent.withValues(alpha: 0.3),
                        child: InkWell(
                          onTap: () => _onTap(context, _postTabIndex),
                          child: Tooltip(
                            message: 'Post a new job',
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                    color: AppColors.accent
                                        .withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _NavIcon(
                    icon: Icons.auto_awesome_outlined,
                    activeIcon: Icons.auto_awesome,
                    tooltip: 'AI Assistant',
                    isActive: navigationShell.currentIndex == 3,
                    onTap: () => _onTap(context, 3),
                  ),
                  _NavIcon(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    tooltip: 'Profile',
                    isActive: navigationShell.currentIndex == 4,
                    onTap: () => _onTap(context, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.activeIcon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: 28,
          child: Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppColors.primary : AppColors.textMuted,
            size: 26,
            semanticLabel: tooltip,
          ),
        ),
      ),
    );
  }
}
