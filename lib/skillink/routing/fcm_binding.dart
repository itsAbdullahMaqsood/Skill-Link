import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/in_app_notification.dart';
import 'package:skilllink/router/app_router.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/notifications/view_models/notifications_view_model.dart';

final fcmBindingProvider = Provider<int>((ref) {
  ref.listen<AuthState>(
    authViewModelProvider,
    (previous, next) {
      final fcm = ref.read(fcmServiceProvider);
      void onForegroundItem(InAppNotification n) {
        ref.read(notificationsViewModelProvider.notifier).add(n);
      }

      if (next.bootstrapping) return;

      if (!next.isAuthenticated) {
        fcm.resetListeners();
        ref.read(notificationsViewModelProvider.notifier).clear();
        return;
      }

      final router = ref.read(appRouterProvider);
      fcm.attach(router: router, onForegroundFeedItem: onForegroundItem);

      final prev = previous;
      if (prev != null &&
          prev.isAuthenticated &&
          next.isAuthenticated &&
          prev.user?.id == next.user?.id &&
          !prev.bootstrapping &&
          !next.bootstrapping) {
        return;
      }

      unawaited(fcm.init());
    },
    fireImmediately: true,
  );
  return 0;
});
