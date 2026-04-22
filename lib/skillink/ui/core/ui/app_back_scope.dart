import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBackScope extends StatelessWidget {
  const AppBackScope({
    super.key,
    required this.fallbackPath,
    required this.child,
  });

  final String fallbackPath;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go(fallbackPath);
      },
      child: child,
    );
  }
}
