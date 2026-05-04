import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/data/services/worker_location_publisher.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

/// Auto-manages [WorkerLocationPublisher] lifecycle so the homeowner sees the
/// worker's live location for the *entire* active window of a service request
/// — from the moment the worker interacts (`worker_accepted` / `bid_received`)
/// through negotiation, en route, and on site (`arrived` / `in_progress`) —
/// without requiring the worker to manually tap "On the way" first.
///
/// Mounted globally in `SkillChainApp.build` (alongside `fcmBindingProvider`
/// and `chatBindingProvider`) so the worker is auto-broadcasting any time
/// they're signed in as a worker and have an active job. The binding is a
/// no-op for unauthenticated users and for homeowners.
///
/// Permission policy: we do NOT auto-prompt from this background listener.
/// We only check current status with [Permission.locationWhenInUse.status]
/// and silently skip if not already granted, leaving the explicit "On the
/// way" button (which DOES prompt) as the worker-driven fallback.
final workerLiveLocationBindingProvider = Provider<int>((ref) {
  bool running = false;
  String? runningWorkerId;
  bool evaluating = false;
  // Tracks the userId for which we've already issued a one-shot
  // invalidate-to-retry on the requests provider. Prevents an infinite
  // invalidate→error→listener→invalidate loop if the retry also fails.
  String? retriedReqsForUserId;

  Future<void> ensureStopped() async {
    if (!running) return;
    debugPrint(
      '[WorkerLiveLocationBinding] no active jobs — stopping publisher',
    );
    try {
      await ref.read(workerLocationPublisherProvider).stop();
    } catch (e, st) {
      debugPrint('[WorkerLiveLocationBinding] stop failed: $e\n$st');
    }
    running = false;
    runningWorkerId = null;
  }

  bool isLocationShareWindow(ServiceRequest r) {
    if (r.cancelled) return false;
    return r.status == ServiceRequestStatus.workerAccepted ||
        r.status == ServiceRequestStatus.bidReceived ||
        r.status == ServiceRequestStatus.bidAccepted ||
        r.status == ServiceRequestStatus.onTheWay ||
        r.status == ServiceRequestStatus.arrived ||
        r.status == ServiceRequestStatus.inProgress;
  }

  Future<bool> isPermissionAlreadyGranted() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  Future<void> evaluate() async {
    if (evaluating) return;
    evaluating = true;
    try {
      final auth = ref.read(authViewModelProvider);

      // Don't act while auth is still resolving — we'd otherwise read
      // myServiceRequestsProvider with no access token and trigger a
      // "Token not provided" failure that polls until invalidated.
      if (auth.bootstrapping) return;

      final user = auth.user;

      // Only authenticated workers broadcast. Homeowners and signed-out
      // sessions are a no-op (and trigger a teardown if a previous worker
      // session was running). Also reset the retry guard so the next
      // worker session gets its own one-shot invalidate.
      if (user == null || user.role != UserRole.worker) {
        retriedReqsForUserId = null;
        await ensureStopped();
        return;
      }

      final reqsAsync = ref.read(
        myServiceRequestsProvider(ServiceRequestRole.worker),
      );

      // If the previous fetch failed (typically because we polled before
      // the access token was available), retry ONCE per signed-in worker
      // now that we have a valid session. Any subsequent failure stays in
      // error state until something else triggers an invalidation (e.g. an
      // action controller after a user-driven mutation, or pull-to-refresh
      // on a screen).
      if (reqsAsync.hasError && !reqsAsync.isLoading) {
        if (retriedReqsForUserId == user.id) {
          debugPrint(
            '[WorkerLiveLocationBinding] my-service-requests still in '
            'error state after one retry; not looping. Last error: '
            '${reqsAsync.error}',
          );
          return;
        }
        debugPrint(
          '[WorkerLiveLocationBinding] my-service-requests is in error '
          'state — invalidating to retry now that auth is ready: '
          '${reqsAsync.error}',
        );
        retriedReqsForUserId = user.id;
        ref.invalidate(
          myServiceRequestsProvider(ServiceRequestRole.worker),
        );
        return;
      }

      final reqs = reqsAsync.valueOrNull;
      if (reqs == null) {
        // Still loading or has no data yet — the listener will fire again
        // when it resolves.
        return;
      }

      final activeCount = reqs.where(isLocationShareWindow).length;
      final uid = user.id;

      if (activeCount > 0 && uid.isNotEmpty) {
        if (running && runningWorkerId == uid) return;
        if (!await isPermissionAlreadyGranted()) {
          debugPrint(
            '[WorkerLiveLocationBinding] $activeCount active job(s) but '
            'location permission not granted — skipping silent start. '
            'Worker can grant via the explicit "On the way" button.',
          );
          return;
        }
        debugPrint(
          '[WorkerLiveLocationBinding] starting publisher for '
          'workerId=$uid (activeCount=$activeCount)',
        );
        try {
          await ref
              .read(workerLocationPublisherProvider)
              .start(workerId: uid);
          running = true;
          runningWorkerId = uid;
        } catch (e, st) {
          debugPrint('[WorkerLiveLocationBinding] start failed: $e\n$st');
        }
      } else {
        await ensureStopped();
      }
    } finally {
      evaluating = false;
    }
  }

  // React to auth changes (login / logout / role switch).
  ref.listen<({bool bootstrapping, String? userId, UserRole? role})>(
    authViewModelProvider.select(
      (s) => (
        bootstrapping: s.bootstrapping,
        userId: s.user?.id,
        role: s.user?.role,
      ),
    ),
    (prev, next) {
      if (next.bootstrapping) return;
      unawaited(evaluate());
    },
    fireImmediately: true,
  );

  // React to service-request changes for the signed-in worker. Note: we do
  // NOT use fireImmediately here. Eagerly subscribing the provider on app
  // boot — before auth has bootstrapped — causes the repo to fetch with no
  // access token and fail. The auth listener above will trigger evaluate()
  // (and an invalidate-to-retry if needed) once auth resolves.
  ref.listen<AsyncValue<List<ServiceRequest>>>(
    myServiceRequestsProvider(ServiceRequestRole.worker),
    (prev, next) => unawaited(evaluate()),
  );

  ref.onDispose(() {
    if (running) {
      // Fire-and-forget — provider is being torn down (app shutdown / scope
      // disposal). The publisher's own onDispose also calls stop() as a
      // safety net.
      unawaited(ref.read(workerLocationPublisherProvider).stop());
    }
  });

  return 0;
});
