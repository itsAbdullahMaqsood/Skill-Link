import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/payment_method.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';

/// Minimal [Job] used only by the completion-amount prompt UI for service requests.
Job jobForCompletionPrompt(ServiceRequest sr) {
  final price = sr.acceptedBid?.amount.toDouble();
  final worker = sr.assignedWorker;
  final trade = (worker != null && worker.services.isNotEmpty)
      ? worker.services.first.name
      : 'service';
  final sched = DateTime.tryParse(sr.scheduledServiceDate) ?? DateTime.now();
  final workerId = sr.requestedWorkerId.isNotEmpty
      ? sr.requestedWorkerId
      : (worker?.id ?? '');
  return Job(
    jobId: sr.id,
    userId: sr.requestingUserId,
    workerId: workerId.isEmpty ? null : workerId,
    serviceType: trade,
    status: JobStatus.completed,
    scheduledDate: sched,
    finalPrice: price,
    description: sr.description.isEmpty ? 'Service request' : sr.description,
    address: StructuredAddress(
      street: sr.serviceAddress,
      area: '',
      city: '',
      postalCode: '',
    ),
    paymentMethod: PaymentMethod.cash,
    createdAt: sr.createdAt ?? DateTime.now(),
  );
}
