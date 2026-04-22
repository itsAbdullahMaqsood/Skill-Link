import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/core/network/auth_interceptor.dart';
import 'package:skilllink/router/app_router.dart';
import 'package:skilllink/services/api_service.dart';
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/services/chat/chat_service.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/routing/fcm_binding.dart';
import 'package:skilllink/skillink/ui/core/themes/app_theme.dart'
    as labour_theme;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
  }

  final authService = AuthService();
  final chatService = ChatService.instance;

  ApiService.configureAuth(
    AuthInterceptorCallbacks(
      getAccessToken: authService.getAccessToken,
      refreshToken: authService.refreshAccessToken,
      onLogoutRequired: () {
        unawaited(authService.logout());
      },
      attachAccessToken: () async => !(await authService.isLabourBackend()),
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        skillChainAuthServiceProvider.overrideWithValue(authService),
        skillChainChatServiceProvider.overrideWithValue(chatService),
      ],
      child: const SkillChainApp(),
    ),
  );
}

class SkillChainApp extends ConsumerWidget {
  const SkillChainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(fcmBindingProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Skill Link',
      debugShowCheckedModeBanner: false,
      theme: labour_theme.AppTheme.light,
      routerConfig: router,
    );
  }
}
