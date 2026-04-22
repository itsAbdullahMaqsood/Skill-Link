import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/in_app_notification.dart';
import 'package:skilllink/skillink/routing/routes.dart';

void navigateFromNotificationPayload(
  GoRouter router,
  Map<String, dynamic> data,
) {
  final type = parseNotificationType(data['type'] as String?);
  final id = (data['id'] as String?)?.trim() ?? '';

  switch (type) {
    case InAppNotificationType.job:
      if (id.isNotEmpty) {
        router.push(Routes.jobTracking(id));
      } else {
        router.push(Routes.notifications);
      }
      break;
    case InAppNotificationType.anomaly:
      if (id.isNotEmpty) {
        router.push(Routes.alertDetail(id));
      } else {
        router.push(Routes.notifications);
      }
      break;
    case InAppNotificationType.system:
    case null:
      router.push(Routes.notifications);
      break;
  }
}
