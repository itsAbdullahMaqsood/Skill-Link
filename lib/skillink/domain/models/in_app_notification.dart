import 'package:freezed_annotation/freezed_annotation.dart';

part 'in_app_notification.freezed.dart';

@freezed
abstract class InAppNotification with _$InAppNotification {
  const factory InAppNotification({
    required String id,
    required String title,
    required String body,
    required InAppNotificationType type,
    required String targetId,
    required DateTime createdAt,
    @Default(false) bool read,
  }) = _InAppNotification;
}

enum InAppNotificationType {
  job,
  anomaly,
  system,
}

InAppNotificationType? parseNotificationType(String? raw) {
  switch (raw) {
    case 'job':
      return InAppNotificationType.job;
    case 'anomaly':
      return InAppNotificationType.anomaly;
    case 'system':
      return InAppNotificationType.system;
    default:
      return null;
  }
}

extension InAppNotificationTypePayload on InAppNotificationType {
  String get payloadValue => name;
}
