import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/data/services/worker_location_publisher.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/utils/result.dart';

class ServiceRequestActionResult {
  const ServiceRequestActionResult.ok({this.message}) : success = true;
  const ServiceRequestActionResult.err(this.message) : success = false;

  final bool success;
  final String? message;
}

class ServiceRequestActionsState {
  const ServiceRequestActionsState({this.isSubmitting = false});
  final bool isSubmitting;

  ServiceRequestActionsState copyWith({bool? isSubmitting}) =>
      ServiceRequestActionsState(isSubmitting: isSubmitting ?? this.isSubmitting);
}

class ServiceRequestActionsController
    extends StateNotifier<ServiceRequestActionsState> {
  ServiceRequestActionsController({required Ref ref, required this.requestId})
      : _ref = ref,
        super(const ServiceRequestActionsState());

  final Ref _ref;
  final String requestId;

  ServiceRequestRepository get _repo =>
      _ref.read(serviceRequestRepositoryProvider);

  Future<ServiceRequestActionResult> counterOffer({
    required num amount,
    required num visitingFee,
  }) =>
      _run(() => _repo.customerCounterOffer(
            id: requestId,
            amount: amount,
            visitingFee: visitingFee,
          ));

  Future<ServiceRequestActionResult> acceptBid() =>
      _run(() => _repo.customerAcceptBid(requestId));

  Future<ServiceRequestActionResult> cancel() =>
      _run(() => _repo.cancel(requestId));


  Future<ServiceRequestActionResult> workerAccept() =>
      _run(() => _repo.workerAccept(requestId));

  Future<ServiceRequestActionResult> workerBid({
    required num amount,
    required num visitingFee,
  }) =>
      _run(() => _repo.workerBid(
            id: requestId,
            amount: amount,
            visitingFee: visitingFee,
          ));

  Future<ServiceRequestActionResult> workerAcceptCustomerCounter({
    required num amount,
    required num visitingFee,
  }) async {
    final inner = await workerBid(amount: amount, visitingFee: visitingFee);
    if (!inner.success) return inner;
    return const ServiceRequestActionResult.ok(
      message: 'Accepted. Waiting for customer to finalise.',
    );
  }

  Future<ServiceRequestActionResult> workerOnTheWay() async {
    debugPrint('[workerOnTheWay] requested for requestId=$requestId');
    if (state.isSubmitting) {
      return const ServiceRequestActionResult.err('Please wait…');
    }

    final perm = await WorkerLocationPublisher.ensurePermission();
    debugPrint(
      '[workerOnTheWay] permission granted=${perm.granted} '
      'servicesEnabled=${perm.servicesEnabled} message=${perm.message}',
    );
    if (!perm.granted) {
      return ServiceRequestActionResult.err(
        perm.message ?? 'Location permission required.',
      );
    }

    // Hold the submitting flag across BOTH the publisher's initial GPS fix and
    // the backend status flip. The publisher's start() does a high-accuracy
    // getCurrentPosition + RTDB push (typically 1–3s), so the action button
    // must stay disabled / show its spinner the entire time, otherwise the
    // worker can double-tap and the homeowner sees a blank "Waiting for
    // worker to share location…" skeleton.
    state = state.copyWith(isSubmitting: true);
    try {
      // 1) Push an initial fix to RTDB BEFORE flipping the backend status, so
      //    the homeowner's LiveTrackingMap (which only mounts when status ==
      //    onTheWay) renders the worker's real position on its very first
      //    frame instead of the waiting skeleton.
      final uid = _ref.read(authViewModelProvider).user?.id;
      if (uid != null && uid.isNotEmpty) {
        debugPrint(
          '[workerOnTheWay] starting publisher BEFORE backend flip '
          'workerId=$uid',
        );
        try {
          await _ref
              .read(workerLocationPublisherProvider)
              .start(workerId: uid);
        } catch (e, st) {
          debugPrint('[workerOnTheWay] publisher.start() failed: $e\n$st');
        }
      } else {
        debugPrint(
          '[workerOnTheWay] SKIP publisher.start() — auth user.id is empty',
        );
      }

      // 2) Flip the backend status. We can't reuse _run() here because it
      //    owns its own isSubmitting toggle and we need a single span across
      //    both phases.
      final res = await _repo.workerOnTheWay(requestId);
      final result = res.when(
        success: (_) {
          _invalidateRelated();
          return const ServiceRequestActionResult.ok();
        },
        failure: (message, _) => ServiceRequestActionResult.err(message),
      );
      debugPrint(
        '[workerOnTheWay] backend result success=${result.success} '
        'message=${result.message}',
      );

      // 3) Roll back the publisher if the backend rejected the transition,
      //    so we don't keep broadcasting for a request that isn't actually
      //    marked en route.
      if (!result.success && uid != null && uid.isNotEmpty) {
        debugPrint(
          '[workerOnTheWay] backend failed — stopping publisher to roll back',
        );
        unawaited(_ref.read(workerLocationPublisherProvider).stop());
      }

      return result;
    } finally {
      if (mounted) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }

  Future<ServiceRequestActionResult> workerArrived() async {
    if (state.isSubmitting) {
      return const ServiceRequestActionResult.err('Please wait…');
    }
    state = state.copyWith(isSubmitting: true);
    try {
      final res = await _repo.workerArrived(requestId);
      final result = res.when(
        success: (_) {
          _invalidateRelated();
          return const ServiceRequestActionResult.ok();
        },
        failure: (message, _) => ServiceRequestActionResult.err(message),
      );

      // Await the publisher tear-down (foreground service + RTDB clear) so
      // the action's spinner stays up until live-location sharing has
      // actually stopped. Keeps the "Arrived" transition feeling final and
      // prevents a tiny window where the homeowner's map could still pull
      // a stale fix.
      if (result.success) {
        try {
          await _ref.read(workerLocationPublisherProvider).stop();
        } catch (e, st) {
          debugPrint('[workerArrived] publisher.stop() failed: $e\n$st');
        }
      }

      return result;
    } finally {
      if (mounted) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }

  Future<ServiceRequestActionResult> workerStart() =>
      _run(() => _repo.workerStart(requestId));

  Future<ServiceRequestActionResult> workerComplete() =>
      _run(() => _repo.workerComplete(requestId));

  Future<ServiceRequestActionResult> _run(
    Future<Result<ServiceRequest>> Function() fn,
  ) async {
    if (state.isSubmitting) {
      return const ServiceRequestActionResult.err('Please wait…');
    }
    state = state.copyWith(isSubmitting: true);
    try {
      final res = await fn();
      return res.when(
        success: (_) {
          _invalidateRelated();
          return const ServiceRequestActionResult.ok();
        },
        failure: (message, _) => ServiceRequestActionResult.err(message),
      );
    } finally {
      if (mounted) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }

  void _invalidateRelated() {
    _ref.invalidate(serviceRequestByIdProvider(requestId));
    _ref.invalidate(myServiceRequestsProvider(ServiceRequestRole.customer));
    _ref.invalidate(myServiceRequestsProvider(ServiceRequestRole.worker));
  }
}

final serviceRequestActionsControllerProvider = StateNotifierProvider
    .autoDispose
    .family<ServiceRequestActionsController, ServiceRequestActionsState,
        String>((ref, id) {
  return ServiceRequestActionsController(ref: ref, requestId: id);
});
