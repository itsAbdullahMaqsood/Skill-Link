import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellBackScope extends StatelessWidget {
  const ShellBackScope({
    super.key,
    required this.navigationShell,
    this.homeBranchIndex = 0,
    required this.child,
  });

  final StatefulNavigationShell navigationShell;
  final int homeBranchIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: navigationShell.currentIndex == homeBranchIndex,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && navigationShell.currentIndex != homeBranchIndex) {
          navigationShell.goBranch(homeBranchIndex);
        }
      },
      child: child,
    );
  }
}
