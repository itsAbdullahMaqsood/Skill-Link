import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skilllink/skillink/data/services/worker_live_location_service.dart';

class LocationPermissionResult {
  const LocationPermissionResult({
    required this.granted,
    this.servicesEnabled = true,
    this.message,
  });
  final bool granted;
  final bool servicesEnabled;
  final String? message;
}

/// Streams the worker's GPS while they're en route and pushes to RTDB.
///
/// Throttle: ≥15s between writes AND ≥25m moved.
class WorkerLocationPublisher {
  WorkerLocationPublisher({required WorkerLiveLocationService service})
      : _service = service;

  final WorkerLiveLocationService _service;

  StreamSubscription<Position>? _sub;
  Timer? _heartbeat;
  String? _workerId;
  Position? _lastPushed;
  DateTime? _lastPushAt;
  bool _running = false;

  bool get isRunning => _running;
  String? get currentWorkerId => _workerId;

  static Future<LocationPermissionResult> ensurePermission() async {
    final servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      return const LocationPermissionResult(
        granted: false,
        servicesEnabled: false,
        message: 'Turn on device location to share your route.',
      );
    }
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) status = await Permission.locationWhenInUse.request();
    if (status.isPermanentlyDenied) {
      return const LocationPermissionResult(
        granted: false,
        message:
            'Location permission is permanently denied. Open settings to allow access.',
      );
    }
    if (!status.isGranted) {
      return const LocationPermissionResult(
        granted: false,
        message: 'Location permission is required to mark on the way.',
      );
    }
    return const LocationPermissionResult(granted: true);
  }

  Future<void> start({required String workerId}) async {
    if (_running && _workerId == workerId) {
      debugPrint(
        '[WorkerLocationPublisher] start() ignored — already running '
        'for workerId=$workerId',
      );
      return;
    }
    await stop();
    _workerId = workerId;
    _running = true;
    debugPrint('[WorkerLocationPublisher] start() workerId=$workerId');

    await _initForegroundService();
    await _startForegroundService();

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      debugPrint(
        '[WorkerLocationPublisher] initial fix '
        'lat=${pos.latitude} lng=${pos.longitude} — pushing',
      );
      await _maybePush(pos, force: true);
    } on Exception catch (e) {
      debugPrint('[WorkerLocationPublisher] initial fix FAILED: $e');
    }

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      ),
    ).listen(
      (pos) {
        debugPrint(
          '[WorkerLocationPublisher] stream emit '
          'lat=${pos.latitude} lng=${pos.longitude}',
        );
        _maybePush(pos);
      },
      onError: (Object e) =>
          debugPrint('[WorkerLocationPublisher] stream ERROR: $e'),
    );
    debugPrint(
      '[WorkerLocationPublisher] position stream subscribed '
      '(distanceFilter=25m)',
    );

    // Heartbeat: re-push current GPS every 20s even if stationary so the
    // homeowner's RTDB subscription gets a recent `updatedAt` timestamp and
    // the marker doesn't appear stuck.
    _heartbeat = Timer.periodic(const Duration(seconds: 20), (_) async {
      if (!_running) {
        debugPrint(
          '[WorkerLocationPublisher] heartbeat tick skipped — not running',
        );
        return;
      }
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        debugPrint(
          '[WorkerLocationPublisher] heartbeat tick '
          'lat=${pos.latitude} lng=${pos.longitude} — pushing',
        );
        await _maybePush(pos, force: true);
      } on Exception catch (e) {
        debugPrint('[WorkerLocationPublisher] heartbeat FAILED: $e');
      }
    });
    debugPrint(
      '[WorkerLocationPublisher] heartbeat scheduled every 20s',
    );
  }

  Future<void> stop() async {
    _heartbeat?.cancel();
    _heartbeat = null;
    final sub = _sub;
    _sub = null;
    if (sub != null) {
      await sub.cancel();
    }
    final id = _workerId;
    _workerId = null;
    _lastPushed = null;
    _lastPushAt = null;
    _running = false;
    if (id != null) {
      await _service.clear(id);
    }
    await _stopForegroundService();
  }

  Future<void> _maybePush(Position pos, {bool force = false}) async {
    final id = _workerId;
    if (id == null) {
      debugPrint(
        '[WorkerLocationPublisher] _maybePush skipped — no workerId set',
      );
      return;
    }
    if (!force) {
      final last = _lastPushed;
      final lastAt = _lastPushAt;
      if (last != null && lastAt != null) {
        final dt = DateTime.now().difference(lastAt);
        final dist = Geolocator.distanceBetween(
          last.latitude,
          last.longitude,
          pos.latitude,
          pos.longitude,
        );
        if (dt < const Duration(seconds: 15) && dist < 25) {
          debugPrint(
            '[WorkerLocationPublisher] _maybePush throttled '
            '(${dt.inSeconds}s, ${dist.toStringAsFixed(1)}m)',
          );
          return;
        }
      }
    }
    _lastPushed = pos;
    _lastPushAt = DateTime.now();
    await _service.publish(
      workerId: id,
      lat: pos.latitude,
      lng: pos.longitude,
    );
  }

  Future<void> _initForegroundService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'skilllink_location_share',
        channelName: 'Live Location',
        channelDescription:
            'Used while you are on the way to a customer to share live location.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(15000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  Future<void> _startForegroundService() async {
    try {
      if (await FlutterForegroundTask.isRunningService) return;
      await FlutterForegroundTask.startService(
        notificationTitle: 'Sharing live location',
        notificationText: 'Your customer can see your route while you are on the way.',
      );
    } catch (e) {
      debugPrint('Foreground service start failed: $e');
    }
  }

  Future<void> _stopForegroundService() async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (e) {
      debugPrint('Foreground service stop failed: $e');
    }
  }
}
