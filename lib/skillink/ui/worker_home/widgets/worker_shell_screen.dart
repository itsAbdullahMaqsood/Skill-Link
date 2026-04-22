import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/ui/app_drawer.dart';
import 'package:skilllink/skillink/ui/core/ui/shell_back_scope.dart';

class WorkerShellScreen extends StatelessWidget {
  const WorkerShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
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
                    tooltip: 'Jobs',
                    isActive: navigationShell.currentIndex == 0,
                    onTap: () => _onTap(0),
                  ),
                  _NavIcon(
                    icon: Icons.storefront_outlined,
                    activeIcon: Icons.storefront_rounded,
                    tooltip: 'Marketplace',
                    isActive: navigationShell.currentIndex == 1,
                    onTap: () => _onTap(1),
                  ),
                  _NavIcon(
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble_rounded,
                    tooltip: 'Chat',
                    isActive: navigationShell.currentIndex == 2,
                    onTap: () => _onTap(2),
                  ),
                  _NavIcon(
                    icon: Icons.inbox_outlined,
                    activeIcon: Icons.inbox_rounded,
                    tooltip: 'Incoming Requests',
                    isActive: navigationShell.currentIndex == 3,
                    onTap: () => _onTap(3),
                  ),
                  _NavIcon(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    tooltip: 'Profile',
                    isActive: navigationShell.currentIndex == 4,
                    onTap: () => _onTap(4),
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
