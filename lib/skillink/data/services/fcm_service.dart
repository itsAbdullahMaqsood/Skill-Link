import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/in_app_notification.dart';

class FcmService {
  FcmService();

  // ignore: unused_field
  GoRouter? _router;
  // ignore: unused_field
  void Function(InAppNotification event)? _onForegroundFeedItem;

  void attach({
    required GoRouter router,
    void Function(InAppNotification event)? onForegroundFeedItem,
  }) {
    _router = router;
    _onForegroundFeedItem = onForegroundFeedItem;
  }

  Future<void> init() async {
  }

  void resetListeners() {}

  void dispose() {}
}
