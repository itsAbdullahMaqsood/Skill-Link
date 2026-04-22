import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
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
    required String currency,
  }) =>
      _run(() => _repo.customerCounterOffer(
            id: requestId,
            amount: amount,
            currency: currency,
          ));

  Future<ServiceRequestActionResult> acceptBid() =>
      _run(() => _repo.customerAcceptBid(requestId));

  Future<ServiceRequestActionResult> cancel() =>
      _run(() => _repo.cancel(requestId));


  Future<ServiceRequestActionResult> workerAccept() =>
      _run(() => _repo.workerAccept(requestId));

  Future<ServiceRequestActionResult> workerBid({
    required num amount,
    required String currency,
  }) =>
      _run(() => _repo.workerBid(
            id: requestId,
            amount: amount,
            currency: currency,
          ));

  Future<ServiceRequestActionResult> workerAcceptCustomerCounter({
    required num amount,
    required String currency,
  }) async {
    final inner = await workerBid(amount: amount, currency: currency);
    if (!inner.success) return inner;
    return const ServiceRequestActionResult.ok(
      message: 'Accepted. Waiting for customer to finalise.',
    );
  }

  Future<ServiceRequestActionResult> workerOnTheWay() =>
      _run(() => _repo.workerOnTheWay(requestId));

  Future<ServiceRequestActionResult> workerArrived() =>
      _run(() => _repo.workerArrived(requestId));

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
        success: (sr) {
          _invalidateRelated();
          if (sr.status == ServiceRequestStatus.completed) {
            unawaited(
              _ref.read(completionReportRepositoryProvider).openReport(
                    jobId: sr.id,
                    createdAt: DateTime.now(),
                  ),
            );
          }
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
