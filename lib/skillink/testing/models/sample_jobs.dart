import 'package:skilllink/skillink/domain/models/bid.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/payment_method.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';

class SampleJobs {
  SampleJobs._();

  static final DateTime _now = DateTime.now();

  static final StructuredAddress _address = const StructuredAddress(
    street: '45-B Main Boulevard',
    area: 'Gulberg III',
    city: 'Lahore',
    postalCode: '54660',
  );

  static final Job activeJob = Job(
    jobId: 'job_active_1',
    userId: 'homeowner_001',
    workerId: 'w_003',
    serviceType: 'hvac',
    status: JobStatus.onTheWay,
    scheduledDate: _now.add(const Duration(hours: 1)),
    finalPrice: 2500,
    bidHistory: [
      Bid(
        bidderId: 'w_003',
        amount: 2500,
        submittedAt: _now.subtract(const Duration(minutes: 45)),
        accepted: true,
      ),
    ],
    description: 'AC is not cooling. Possible gas leak.',
    photoUrls: const [],
    address: _address,
    paymentMethod: PaymentMethod.cash,
    createdAt: _now.subtract(const Duration(hours: 2)),
  );

  static final Job demoCompletedAwaitingReport = Job(
    jobId: 'job_demo_completed',
    userId: 'homeowner_001',
    workerId: 'worker_001',
    serviceType: 'plumber',
    status: JobStatus.completed,
    scheduledDate: _now.subtract(const Duration(hours: 4)),
    finalPrice: 2400,
    description: 'Bathroom faucet replacement.',
    address: _address,
    paymentMethod: PaymentMethod.cash,
    paid: true,
    paidAt: _now.subtract(const Duration(minutes: 20)),
    createdAt: _now.subtract(const Duration(hours: 6)),
  );

  static final List<Job> recentJobs = [
    Job(
      jobId: 'job_past_1',
      userId: 'homeowner_001',
      workerId: 'w_001',
      serviceType: 'electrician',
      status: JobStatus.completed,
      scheduledDate: _now.subtract(const Duration(days: 4)),
      finalPrice: 1800,
      description: 'Light switch replacement in living room.',
      address: _address,
      paymentMethod: PaymentMethod.cash,
      paid: true,
      paidAt: _now.subtract(const Duration(days: 4)),
      createdAt: _now.subtract(const Duration(days: 5)),
    ),
    Job(
      jobId: 'job_past_2',
      userId: 'homeowner_001',
      workerId: 'w_002',
      serviceType: 'plumber',
      status: JobStatus.completed,
      scheduledDate: _now.subtract(const Duration(days: 12)),
      finalPrice: 3200,
      description: 'Kitchen sink leak.',
      address: _address,
      paymentMethod: PaymentMethod.cash,
      paid: true,
      paidAt: _now.subtract(const Duration(days: 12)),
      createdAt: _now.subtract(const Duration(days: 13)),
    ),
    Job(
      jobId: 'job_past_3',
      userId: 'homeowner_001',
      workerId: 'w_004',
      serviceType: 'carpenter',
      status: JobStatus.cancelledNoPenalty,
      scheduledDate: _now.subtract(const Duration(days: 21)),
      description: 'Wardrobe door repair — cancelled, self-fixed.',
      address: _address,
      paymentMethod: PaymentMethod.cash,
      createdAt: _now.subtract(const Duration(days: 21)),
    ),
  ];

  static List<Job> incomingWorkerOffers(DateTime now) {
    const address1 = StructuredAddress(
      street: '12-A Canal Road',
      area: 'Model Town',
      city: 'Lahore',
      postalCode: '54700',
    );
    return [
      Job(
        jobId: 'job_inc_1',
        userId: 'homeowner_002',
        serviceType: 'electrician',
        status: JobStatus.posted,
        scheduledDate: now.add(const Duration(hours: 3)),
        description: 'Multiple outlets not working in the bedroom.',
        address: address1,
        paymentMethod: PaymentMethod.cash,
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      Job(
        jobId: 'job_inc_2',
        userId: 'homeowner_003',
        serviceType: 'electrician',
        status: JobStatus.posted,
        scheduledDate: now.add(const Duration(hours: 6)),
        description: 'Ceiling fan sparking when turned on.',
        address: const StructuredAddress(
          street: '78 Shah Jamal',
          area: 'Ichra',
          city: 'Lahore',
          postalCode: '54000',
        ),
        paymentMethod: PaymentMethod.cash,
        createdAt: now.subtract(const Duration(minutes: 12)),
      ),
    ];
  }
}
