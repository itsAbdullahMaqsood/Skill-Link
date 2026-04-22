enum ServiceRequestPaymentMethod {
  cash,
  card,
  bankTransfer,
  digitalWallet,
  online;

  String get wire => switch (this) {
        ServiceRequestPaymentMethod.cash => 'cash',
        ServiceRequestPaymentMethod.card => 'card',
        ServiceRequestPaymentMethod.bankTransfer => 'bank_transfer',
        ServiceRequestPaymentMethod.digitalWallet => 'digital_wallet',
        ServiceRequestPaymentMethod.online => 'online',
      };

  static ServiceRequestPaymentMethod fromRaw(String? raw) {
    switch ((raw ?? '').trim()) {
      case 'cash':
        return ServiceRequestPaymentMethod.cash;
      case 'card':
        return ServiceRequestPaymentMethod.card;
      case 'bank_transfer':
        return ServiceRequestPaymentMethod.bankTransfer;
      case 'digital_wallet':
        return ServiceRequestPaymentMethod.digitalWallet;
      case 'online':
        return ServiceRequestPaymentMethod.online;
      default:
        return ServiceRequestPaymentMethod.cash;
    }
  }
}

enum ServiceRequestStatus {
  posted,
  workerAccepted,
  bidReceived,
  bidAccepted,
  onTheWay,
  arrived,
  inProgress,
  completed,
  cancelled,
  unknown;

  static ServiceRequestStatus fromRaw(String? raw) {
    switch ((raw ?? '').trim()) {
      case 'posted':
        return ServiceRequestStatus.posted;
      case 'worker_accepted':
        return ServiceRequestStatus.workerAccepted;
      case 'bid_received':
        return ServiceRequestStatus.bidReceived;
      case 'bid_accepted':
        return ServiceRequestStatus.bidAccepted;
      case 'on_the_way':
        return ServiceRequestStatus.onTheWay;
      case 'arrived':
        return ServiceRequestStatus.arrived;
      case 'in_progress':
        return ServiceRequestStatus.inProgress;
      case 'completed':
        return ServiceRequestStatus.completed;
      case 'cancelled':
        return ServiceRequestStatus.cancelled;
      default:
        return ServiceRequestStatus.unknown;
    }
  }
}

class ServiceRequestTimeSlot {
  const ServiceRequestTimeSlot({required this.startTime, required this.endTime});

  final String startTime;
  final String endTime;

  factory ServiceRequestTimeSlot.fromJson(Map<String, dynamic> json) {
    return ServiceRequestTimeSlot(
      startTime: (json['startTime'] ?? '').toString(),
      endTime: (json['endTime'] ?? '').toString(),
    );
  }
}

class ServiceRequestTimelineEntry {
  const ServiceRequestTimelineEntry({
    required this.status,
    required this.label,
    required this.reachedAt,
    required this.isCurrent,
    required this.isCompleted,
    required this.isPending,
  });

  final ServiceRequestStatus status;
  final String label;
  final DateTime? reachedAt;
  final bool isCurrent;
  final bool isCompleted;
  final bool isPending;

  factory ServiceRequestTimelineEntry.fromJson(Map<String, dynamic> json) {
    final reachedRaw = json['reachedAt'];
    return ServiceRequestTimelineEntry(
      status: ServiceRequestStatus.fromRaw(json['status'] as String?),
      label: (json['label'] ?? '').toString(),
      reachedAt: reachedRaw is String && reachedRaw.isNotEmpty
          ? DateTime.tryParse(reachedRaw)
          : null,
      isCurrent: json['isCurrent'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isPending: json['isPending'] as bool? ?? false,
    );
  }
}

enum NegotiationActor {
  worker,
  customer,
  unknown;

  static NegotiationActor fromRaw(String? raw) {
    switch ((raw ?? '').trim()) {
      case 'worker':
        return NegotiationActor.worker;
      case 'customer':
        return NegotiationActor.customer;
      default:
        return NegotiationActor.unknown;
    }
  }
}

class NegotiationOffer {
  const NegotiationOffer({
    required this.sequence,
    required this.actorRole,
    required this.actorUserId,
    required this.amount,
    required this.currency,
    required this.createdAt,
  });

  final int sequence;
  final NegotiationActor actorRole;
  final String actorUserId;
  final num amount;
  final String currency;
  final DateTime? createdAt;

  factory NegotiationOffer.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['amount'];
    final num amount = amountRaw is num
        ? amountRaw
        : num.tryParse(amountRaw?.toString() ?? '') ?? 0;
    return NegotiationOffer(
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      actorRole: NegotiationActor.fromRaw(json['actorRole'] as String?),
      actorUserId: (json['actorUserId'] ?? '').toString(),
      amount: amount,
      currency: (json['currency'] ?? 'PKR').toString(),
      createdAt: ServiceRequest._parseDate(json['createdAt']),
    );
  }
}

class ServiceRequestPartyService {
  const ServiceRequestPartyService({required this.id, required this.name});
  final String id;
  final String name;

  factory ServiceRequestPartyService.fromJson(Map<String, dynamic> json) {
    return ServiceRequestPartyService(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class ServiceRequestParty {
  const ServiceRequestParty({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profilePic,
    required this.ratings,
    required this.reviews,
    required this.role,
    required this.services,
  });

  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;

  final String? profilePic;

  final num ratings;

  final int reviews;

  final String role;

  final List<ServiceRequestPartyService> services;

  factory ServiceRequestParty.fromJson(Map<String, dynamic> json) {
    final servicesRaw = json['services'];
    final services = servicesRaw is List
        ? servicesRaw
            .whereType<Map<String, dynamic>>()
            .map(ServiceRequestPartyService.fromJson)
            .toList()
        : <ServiceRequestPartyService>[];
    final ratingRaw = json['ratings'];
    final num rating = ratingRaw is num
        ? ratingRaw
        : num.tryParse(ratingRaw?.toString() ?? '') ?? 0;
    final reviewsRaw = json['reviews'];
    final int reviews = reviewsRaw is num
        ? reviewsRaw.toInt()
        : int.tryParse(reviewsRaw?.toString() ?? '') ?? 0;
    return ServiceRequestParty(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      profilePic: (json['profilePic'] as String?)?.trim().isEmpty ?? true
          ? null
          : (json['profilePic'] as String).trim(),
      ratings: rating,
      reviews: reviews,
      role: (json['role'] ?? '').toString(),
      services: services,
    );
  }
}

class AcceptedBid {
  const AcceptedBid({
    required this.amount,
    required this.currency,
    required this.acceptedAt,
  });

  final num amount;
  final String currency;
  final DateTime? acceptedAt;

  factory AcceptedBid.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['amount'];
    final num amount = amountRaw is num
        ? amountRaw
        : num.tryParse(amountRaw?.toString() ?? '') ?? 0;
    return AcceptedBid(
      amount: amount,
      currency: (json['currency'] ?? 'PKR').toString(),
      acceptedAt: ServiceRequest._parseDate(json['acceptedAt']),
    );
  }
}

class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.requestingUserId,
    required this.requestedWorkerId,
    required this.description,
    required this.photos,
    required this.scheduledServiceDate,
    required this.timeSlot,
    required this.serviceAddress,
    required this.paymentMethod,
    required this.status,
    required this.cancelled,
    required this.timeline,
    required this.negotiationOffers,
    required this.acceptedBid,
    required this.createdAt,
    required this.updatedAt,
    this.assignedWorker,
    this.requestingCustomer,
  });

  final String id;
  final String requestingUserId;
  final String requestedWorkerId;

  final ServiceRequestParty? assignedWorker;

  final ServiceRequestParty? requestingCustomer;
  final String description;

  final List<String> photos;

  final String scheduledServiceDate;
  final ServiceRequestTimeSlot timeSlot;
  final String serviceAddress;
  final ServiceRequestPaymentMethod paymentMethod;
  final ServiceRequestStatus status;
  final bool cancelled;
  final List<ServiceRequestTimelineEntry> timeline;

  final List<NegotiationOffer> negotiationOffers;

  final AcceptedBid? acceptedBid;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  NegotiationOffer? get latestOffer =>
      negotiationOffers.isEmpty ? null : negotiationOffers.last;

  bool get isTerminal =>
      cancelled ||
      status == ServiceRequestStatus.completed ||
      status == ServiceRequestStatus.cancelled;

  /// Direct bookings / negotiation: worker should treat these as an active job
  /// (e.g. after the homeowner accepts the worker's bid, or after mutual accept).
  bool get showsAsWorkerOngoingJob =>
      !isTerminal &&
      (status == ServiceRequestStatus.workerAccepted ||
          status == ServiceRequestStatus.bidAccepted ||
          status == ServiceRequestStatus.onTheWay ||
          status == ServiceRequestStatus.arrived ||
          status == ServiceRequestStatus.inProgress);

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    final root = json['serviceRequest'] is Map<String, dynamic>
        ? json['serviceRequest'] as Map<String, dynamic>
        : json;

    final photosRaw = root['photos'];
    final photos = photosRaw is List
        ? photosRaw.map((e) => e.toString()).toList()
        : <String>[];

    final timelineRaw = root['timeline'];
    final timeline = timelineRaw is List
        ? timelineRaw
            .whereType<Map<String, dynamic>>()
            .map(ServiceRequestTimelineEntry.fromJson)
            .toList()
        : <ServiceRequestTimelineEntry>[];

    final slot = root['timeSlot'] is Map<String, dynamic>
        ? ServiceRequestTimeSlot.fromJson(
            root['timeSlot'] as Map<String, dynamic>)
        : const ServiceRequestTimeSlot(startTime: '', endTime: '');

    final offersRaw = root['negotiationOffers'];
    final offers = offersRaw is List
        ? offersRaw
            .whereType<Map<String, dynamic>>()
            .map(NegotiationOffer.fromJson)
            .toList()
        : <NegotiationOffer>[];
    offers.sort((a, b) => a.sequence.compareTo(b.sequence));

    final acceptedRaw = root['acceptedBid'];
    final accepted = acceptedRaw is Map<String, dynamic>
        ? AcceptedBid.fromJson(acceptedRaw)
        : null;

    final workerRaw = root['assignedWorker'];
    final worker = workerRaw is Map<String, dynamic>
        ? ServiceRequestParty.fromJson(workerRaw)
        : null;
    final customerRaw = root['requestingCustomer'];
    final customer = customerRaw is Map<String, dynamic>
        ? ServiceRequestParty.fromJson(customerRaw)
        : null;

    return ServiceRequest(
      id: (root['id'] ?? root['_id'] ?? '').toString(),
      requestingUserId: (root['requestingUserId'] ?? '').toString(),
      requestedWorkerId: (root['requestedWorkerId'] ?? '').toString(),
      description: (root['description'] ?? '').toString(),
      photos: photos,
      scheduledServiceDate: (root['scheduledServiceDate'] ?? '').toString(),
      timeSlot: slot,
      serviceAddress: (root['serviceAddress'] ?? '').toString(),
      paymentMethod: ServiceRequestPaymentMethod.fromRaw(
          root['paymentMethod'] as String?),
      status: ServiceRequestStatus.fromRaw(root['status'] as String?),
      cancelled: root['cancelled'] as bool? ?? false,
      timeline: timeline,
      negotiationOffers: offers,
      acceptedBid: accepted,
      createdAt: _parseDate(root['createdAt']),
      updatedAt: _parseDate(root['updatedAt']),
      assignedWorker: worker,
      requestingCustomer: customer,
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}
