import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/router/app_router.dart' as app_router;

class AuthBackScope extends StatelessWidget {
  const AuthBackScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go(app_router.skillTypePath);
      },
      child: child,
    );
  }
}
