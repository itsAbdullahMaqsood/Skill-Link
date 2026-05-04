import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:skilllink/skillink/config/app_constants.dart';

class WorkerLiveLocation {
  const WorkerLiveLocation({
    required this.lat,
    required this.lng,
    required this.updatedAt,
  });

  final double lat;
  final double lng;
  final DateTime updatedAt;
}

/// Pub/sub for a worker's live location while they're on the way to a job.
///
/// Path: `/workerLocations/{workerId}` = `{lat, lng, updatedAt}`.
class WorkerLiveLocationService {
  WorkerLiveLocationService();

  bool get _firebaseReady => Firebase.apps.isNotEmpty;

  /// Use the same explicit `databaseURL` as the IoT live service so the path
  /// is governed by the rules in `AppConstants.firebaseRtdbUrl`'s instance,
  /// not the default-app database (which may differ).
  DatabaseReference _ref(String workerId) {
    final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: AppConstants.firebaseRtdbUrl,
    );
    return db.ref('workerLocations/$workerId');
  }

  /// Publish a single coordinate. Throttling is the publisher's responsibility.
  Future<void> publish({
    required String workerId,
    required double lat,
    required double lng,
  }) async {
    if (!_firebaseReady) {
      debugPrint(
        '[WorkerLiveLocation] SKIP publish: Firebase not initialized. '
        'Ensure Firebase.initializeApp() ran in main() (Android only).',
      );
      return;
    }
    if (workerId.isEmpty) {
      debugPrint('[WorkerLiveLocation] SKIP publish: empty workerId.');
      return;
    }
    try {
      final ref = _ref(workerId);
      await ref.set(<String, dynamic>{
        'lat': lat,
        'lng': lng,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint(
        '[WorkerLiveLocation] published workerId=$workerId '
        'lat=$lat lng=$lng db=${AppConstants.firebaseRtdbUrl}',
      );
      try {
        await ref.onDisconnect().remove();
      } catch (e) {
        debugPrint('[WorkerLiveLocation] onDisconnect setup failed: $e');
      }
    } catch (e, st) {
      debugPrint(
        '[WorkerLiveLocation] PUBLISH FAILED for $workerId: $e\n$st\n'
        'Check RTDB security rules at /workerLocations/$workerId allow writes.',
      );
    }
  }

  Future<void> clear(String workerId) async {
    if (!_firebaseReady || workerId.isEmpty) return;
    try {
      await _ref(workerId).remove();
    } catch (e) {
      debugPrint('WorkerLiveLocationService clear failed: $e');
    }
  }

  Stream<WorkerLiveLocation?> watch(String workerId) {
    if (!_firebaseReady) {
      debugPrint(
        '[WorkerLiveLocation] watch: Firebase not initialized — '
        'returning empty stream. workerId=$workerId',
      );
      return const Stream<WorkerLiveLocation?>.empty();
    }
    if (workerId.isEmpty) {
      debugPrint('[WorkerLiveLocation] watch: empty workerId.');
      return const Stream<WorkerLiveLocation?>.empty();
    }
    debugPrint(
      '[WorkerLiveLocation] watching workerId=$workerId '
      'db=${AppConstants.firebaseRtdbUrl}',
    );
    return _ref(workerId).onValue.map((event) {
      final v = event.snapshot.value;
      if (v is! Map) {
        debugPrint(
          '[WorkerLiveLocation] no value at /workerLocations/$workerId yet.',
        );
        return null;
      }
      final m = Map<String, dynamic>.from(v);
      final lat = (m['lat'] as num?)?.toDouble();
      final lng = (m['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      final tsRaw = (m['updatedAt'] ?? '').toString();
      final ts = DateTime.tryParse(tsRaw) ?? DateTime.now().toUtc();
      debugPrint(
        '[WorkerLiveLocation] received fix workerId=$workerId '
        'lat=$lat lng=$lng updatedAt=$tsRaw',
      );
      return WorkerLiveLocation(lat: lat, lng: lng, updatedAt: ts);
    }).handleError((Object e, StackTrace st) {
      debugPrint(
        '[WorkerLiveLocation] watch ERROR for $workerId: $e\n$st\n'
        'Check RTDB security rules at /workerLocations/$workerId allow reads.',
      );
    });
  }
}
