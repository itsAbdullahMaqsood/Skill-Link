import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/utils/result.dart';

enum ServiceRequestRole {
  customer,
  worker;

  String get wire => name;
}

class CreateServiceRequestInput {
  const CreateServiceRequestInput({
    required this.requestedWorkerId,
    required this.description,
    required this.scheduledServiceDate,
    required this.timeSlotStart,
    required this.timeSlotEnd,
    required this.serviceAddress,
    required this.paymentMethod,
    this.localPhotoPaths = const <String>[],
  });

  final String requestedWorkerId;
  final String description;

  final DateTime scheduledServiceDate;

  final String timeSlotStart;
  final String timeSlotEnd;

  final String serviceAddress;
  final ServiceRequestPaymentMethod paymentMethod;

  final List<String> localPhotoPaths;
}

abstract class ServiceRequestRepository {
  Future<Result<ServiceRequest>> createServiceRequest(
    CreateServiceRequestInput input,
  );

  Future<Result<List<ServiceRequest>>> listMyRequests({
    required ServiceRequestRole role,
  });

  Future<Result<ServiceRequest>> getServiceRequest(String id);


  Future<Result<ServiceRequest>> customerCounterOffer({
    required String id,
    required num amount,
    required String currency,
  });

  Future<Result<ServiceRequest>> customerAcceptBid(String id);

  Future<Result<ServiceRequest>> cancel(String id);


  Future<Result<ServiceRequest>> workerAccept(String id);

  Future<Result<ServiceRequest>> workerBid({
    required String id,
    required num amount,
    required String currency,
  });

  Future<Result<ServiceRequest>> workerOnTheWay(String id);

  Future<Result<ServiceRequest>> workerArrived(String id);

  Future<Result<ServiceRequest>> workerStart(String id);

  Future<Result<ServiceRequest>> workerComplete(String id);
}
