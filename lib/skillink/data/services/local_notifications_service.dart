import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';

class LocalNotificationsService {
  LocalNotificationsService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;
  bool _initFailed = false;

  static const _anomalyChannelId = 'skillink_anomaly_alerts';
  static const _anomalyChannelName = 'Anomaly alerts';
  static const _anomalyChannelDescription =
      'Live alerts when your smart plug detects a power anomaly.';

  void Function(String anomalyId)? onTap;

  Future<void> init() async {
    if (_initialized || _initFailed) return;
    try {
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null || payload.isEmpty) return;
          onTap?.call(payload);
        },
      );
      final android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _anomalyChannelId,
          _anomalyChannelName,
          description: _anomalyChannelDescription,
          importance: Importance.high,
        ),
      );
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          AppConstants.postedJobsNotificationChannelId,
          AppConstants.postedJobsNotificationChannelName,
          description: AppConstants.postedJobsNotificationChannelDescription,
          importance: Importance.defaultImportance,
        ),
      );
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          AppConstants.chatNotificationChannelId,
          AppConstants.chatNotificationChannelName,
          description: AppConstants.chatNotificationChannelDescription,
          importance: Importance.high,
        ),
      );
      await android?.requestNotificationsPermission();
      _initialized = true;
    } catch (e) {
      _initFailed = true;
      if (kDebugMode) {
        debugPrint('LocalNotificationsService.init failed: $e');
      }
    }
  }

  static const _bookTechnicianFooter =
      'Device health may be at risk. Open SkillLink to review the alert and '
      'book a qualified technician.';

  Future<bool> showAnomaly(Anomaly anomaly) async {
    await init();
    if (_initFailed) return false;
    try {
      final title = _titleFor(anomaly);
      final collapsed = _collapsedBody(anomaly);
      final expanded = _expandedBody(anomaly);
      await _plugin.show(
        anomaly.id.hashCode & 0x7fffffff,
        title,
        collapsed,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _anomalyChannelId,
            _anomalyChannelName,
            channelDescription: _anomalyChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            styleInformation: BigTextStyleInformation(
              expanded,
              contentTitle: title,
              summaryText: collapsed,
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: anomaly.id,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LocalNotificationsService.show failed: $e');
      }
      return false;
    }
  }

  Future<bool> showChatMessage({
    required String chatId,
    required String senderName,
    required String preview,
  }) async {
    await init();
    if (_initFailed) return false;
    try {
      await _plugin.show(
        chatId.hashCode & 0x7fffffff,
        senderName,
        preview,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.chatNotificationChannelId,
            AppConstants.chatNotificationChannelName,
            channelDescription:
                AppConstants.chatNotificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.message,
          ),
        ),
        payload: 'chat:$chatId',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LocalNotificationsService.showChatMessage failed: $e');
      }
      return false;
    }
  }

  Future<bool> showPostedJobsAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();
    if (_initFailed) return false;
    try {
      await _plugin.show(
        title.hashCode & 0x7fffffff,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.postedJobsNotificationChannelId,
            AppConstants.postedJobsNotificationChannelName,
            channelDescription:
                AppConstants.postedJobsNotificationChannelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        payload: payload,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LocalNotificationsService.showPostedJobsAlert failed: $e');
      }
      return false;
    }
  }

  String _titleFor(Anomaly a) {
    final label = switch (a.type) {
      'voltage_spike' => 'Voltage spike detected',
      'current_surge' => 'Current surge detected',
      'over_temperature' => 'Overheating detected',
      _ => 'Device health alert',
    };
    final where = a.applianceName;
    if (where == null || where.isEmpty) return label;
    return '$label — $where';
  }

  String _collapsedBody(Anomaly a) {
    final core = (a.message ?? '').trim();
    if (core.isNotEmpty) return core;
    return 'Unusual readings — check your device and book a technician.';
  }

  String _expandedBody(Anomaly a) {
    final buf = StringBuffer();
    final core = (a.message ?? '').trim();
    if (core.isNotEmpty) {
      buf.writeln(core);
    } else {
      buf.writeln(_collapsedBody(a));
    }
    final trade = a.suggestedTrade?.trim();
    if (trade != null && trade.isNotEmpty) {
      buf.writeln();
      buf.write('Suggested service: $trade.');
    }
    buf.writeln();
    buf.writeln(_bookTechnicianFooter);
    return buf.toString().trim();
  }
}
