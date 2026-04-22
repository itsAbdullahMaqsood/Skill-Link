import 'package:skilllink/skillink/domain/models/service_request.dart';

enum OpenJobPostStatus {
  openForBids,

  workerSelected,

  awarded,

  cancelled,
  closed,
  unknown;

  static OpenJobPostStatus fromRaw(String? raw) {
    final n = (raw ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    switch (n) {
      case 'open_for_bids':
      case 'openforbids':
      case 'open':
      case 'open_bids':
      case 'bidding_open':
      case 'accepting_bids':
        return OpenJobPostStatus.openForBids;
      case 'worker_selected':
      case 'workerselected':
        return OpenJobPostStatus.workerSelected;
      case 'awarded':
        return OpenJobPostStatus.awarded;
      case 'cancelled':
      case 'canceled':
        return OpenJobPostStatus.cancelled;
      case 'closed':
        return OpenJobPostStatus.closed;
      default:
        return OpenJobPostStatus.unknown;
    }
  }

  bool get isBiddingClosed => switch (this) {
        OpenJobPostStatus.openForBids => false,
        OpenJobPostStatus.workerSelected => true,
        OpenJobPostStatus.awarded => true,
        OpenJobPostStatus.cancelled => true,
        OpenJobPostStatus.closed => true,
        OpenJobPostStatus.unknown => true,
      };

  String get displayLabel => switch (this) {
        OpenJobPostStatus.openForBids => 'Open for bids',
        OpenJobPostStatus.workerSelected => 'Worker selected',
        OpenJobPostStatus.awarded => 'Worker selected',
        OpenJobPostStatus.cancelled => 'Cancelled',
        OpenJobPostStatus.closed => 'Closed',
        OpenJobPostStatus.unknown => 'Unknown',
      };
}

class OpenJobPost {
  const OpenJobPost({
    required this.id,
    required this.requestingUserId,
    required this.description,
    required this.photos,
    required this.scheduledServiceDate,
    required this.timeSlot,
    required this.serviceAddress,
    required this.paymentMethod,
    required this.status,
    required this.serviceRequestId,
    required this.awardedWorkerId,
    required this.awardedBidId,
    required this.bidCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String requestingUserId;
  final String description;

  final List<String> photos;

  final String scheduledServiceDate;
  final ServiceRequestTimeSlot timeSlot;
  final String serviceAddress;
  final ServiceRequestPaymentMethod paymentMethod;
  final OpenJobPostStatus status;

  final String? serviceRequestId;
  final String? awardedWorkerId;
  final String? awardedBidId;

  final int? bidCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OpenJobPost.fromJson(Map<String, dynamic> json) {
    final root = json['openJobPost'] is Map<String, dynamic>
        ? json['openJobPost'] as Map<String, dynamic>
        : json;

    final photosRaw = root['photos'];
    final photos = photosRaw is List
        ? photosRaw.map((e) => e.toString()).toList()
        : <String>[];

    final slot = root['timeSlot'] is Map<String, dynamic>
        ? ServiceRequestTimeSlot.fromJson(
            root['timeSlot'] as Map<String, dynamic>)
        : const ServiceRequestTimeSlot(startTime: '', endTime: '');

    return OpenJobPost(
      id: (root['id'] ?? root['_id'] ?? '').toString(),
      requestingUserId: (root['requestingUserId'] ??
              root['requesting_user_id'] ??
              root['homeownerId'] ??
              root['userId'] ??
              '')
          .toString(),
      description: (root['description'] ?? '').toString(),
      photos: photos,
      scheduledServiceDate: (root['scheduledServiceDate'] ?? '').toString(),
      timeSlot: slot,
      serviceAddress: (root['serviceAddress'] ?? '').toString(),
      paymentMethod: ServiceRequestPaymentMethod.fromRaw(
          root['paymentMethod'] as String?),
      status: OpenJobPostStatus.fromRaw(root['status'] as String?),
      serviceRequestId: _optionalString(root['serviceRequestId']),
      awardedWorkerId: _optionalString(root['awardedWorkerId']),
      awardedBidId: _optionalString(root['awardedBidId']),
      bidCount: (root['bidCount'] as num?)?.toInt(),
      createdAt: _parseDate(root['createdAt']),
      updatedAt: _parseDate(root['updatedAt']),
    );
  }

  static String? _optionalString(Object? raw) {
    if (raw == null) return null;
    final s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}
