import 'package:skilllink/skillink/domain/models/service_request.dart';

enum ServiceRequestViewer { customer, worker, unknown }

enum ServiceRequestAction {
  workerAccept,
  workerBid,
  workerOnTheWay,
  workerArrived,
  workerStart,
  workerComplete,

  customerCounterOffer,
  customerAcceptBid,

  workerAcceptCounter,

  cancel,
}

ServiceRequestViewer resolveViewer({
  required ServiceRequest request,
  required String? signedInUserId,
}) {
  final id = signedInUserId?.trim();
  if (id == null || id.isEmpty) return ServiceRequestViewer.unknown;
  if (id == request.requestingUserId) return ServiceRequestViewer.customer;
  if (id == request.requestedWorkerId) return ServiceRequestViewer.worker;
  return ServiceRequestViewer.unknown;
}

Set<ServiceRequestAction> availableActions({
  required ServiceRequest request,
  required ServiceRequestViewer viewer,
}) {
  if (viewer == ServiceRequestViewer.unknown) {
    return const <ServiceRequestAction>{};
  }
  if (request.cancelled || request.status == ServiceRequestStatus.cancelled) {
    return const <ServiceRequestAction>{};
  }

  final actions = <ServiceRequestAction>{};

  const cancellableStatuses = {
    ServiceRequestStatus.posted,
    ServiceRequestStatus.workerAccepted,
    ServiceRequestStatus.bidReceived,
    ServiceRequestStatus.bidAccepted,
    ServiceRequestStatus.onTheWay,
  };
  if (cancellableStatuses.contains(request.status)) {
    actions.add(ServiceRequestAction.cancel);
  }

  switch (viewer) {
    case ServiceRequestViewer.worker:
      _workerActions(request, actions);
      break;
    case ServiceRequestViewer.customer:
      _customerActions(request, actions);
      break;
    case ServiceRequestViewer.unknown:
      break;
  }

  return actions;
}

void _workerActions(
  ServiceRequest request,
  Set<ServiceRequestAction> out,
) {
  switch (request.status) {
    case ServiceRequestStatus.posted:
      out.add(ServiceRequestAction.workerAccept);
      break;

    case ServiceRequestStatus.workerAccepted:
      out.add(ServiceRequestAction.workerBid);
      break;

    case ServiceRequestStatus.bidReceived:
      final last = request.latestOffer?.actorRole;
      if (last == NegotiationActor.customer) {
        out.add(ServiceRequestAction.workerBid);
        out.add(ServiceRequestAction.workerAcceptCounter);
      }
      break;

    case ServiceRequestStatus.bidAccepted:
      out.add(ServiceRequestAction.workerOnTheWay);
      break;
    case ServiceRequestStatus.onTheWay:
      out.add(ServiceRequestAction.workerArrived);
      break;
    case ServiceRequestStatus.arrived:
      out.add(ServiceRequestAction.workerStart);
      break;
    case ServiceRequestStatus.inProgress:
      out.add(ServiceRequestAction.workerComplete);
      break;

    case ServiceRequestStatus.completed:
    case ServiceRequestStatus.cancelled:
    case ServiceRequestStatus.unknown:
      break;
  }
}

void _customerActions(
  ServiceRequest request,
  Set<ServiceRequestAction> out,
) {
  if (request.status == ServiceRequestStatus.bidReceived) {
    final last = request.latestOffer?.actorRole;
    if (last == NegotiationActor.worker) {
      out.add(ServiceRequestAction.customerCounterOffer);
      out.add(ServiceRequestAction.customerAcceptBid);
    }
  }
}

bool isWorkerAcceptanceEcho(ServiceRequest request) {
  final offers = request.negotiationOffers;
  if (offers.length < 2) return false;
  final latest = offers.last;
  final prev = offers[offers.length - 2];
  return latest.actorRole == NegotiationActor.worker &&
      prev.actorRole == NegotiationActor.customer &&
      latest.amount == prev.amount &&
      latest.currency == prev.currency;
}
