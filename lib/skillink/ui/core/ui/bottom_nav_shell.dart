import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.body,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
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
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          backgroundColor: AppColors.surface,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
    );
  }
}
