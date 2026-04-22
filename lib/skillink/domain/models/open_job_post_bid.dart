enum OpenJobPostBidStatus {
  pending,

  accepted,

  rejected,

  withdrawn,

  unknown;

  static OpenJobPostBidStatus fromRaw(String? raw) {
    switch ((raw ?? '').trim()) {
      case 'pending':
        return OpenJobPostBidStatus.pending;
      case 'accepted':
        return OpenJobPostBidStatus.accepted;
      case 'rejected':
        return OpenJobPostBidStatus.rejected;
      case 'withdrawn':
        return OpenJobPostBidStatus.withdrawn;
      default:
        return OpenJobPostBidStatus.unknown;
    }
  }

  String get displayLabel => switch (this) {
        OpenJobPostBidStatus.pending => 'Pending',
        OpenJobPostBidStatus.accepted => 'Accepted',
        OpenJobPostBidStatus.rejected => 'Rejected',
        OpenJobPostBidStatus.withdrawn => 'Withdrawn',
        OpenJobPostBidStatus.unknown => 'Unknown',
      };
}

class OpenJobPostBid {
  const OpenJobPostBid({
    required this.id,
    required this.workerId,
    required this.amount,
    required this.currency,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workerId;
  final num amount;
  final String currency;

  final String note;

  final OpenJobPostBidStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OpenJobPostBid.fromJson(Map<String, dynamic> json) {
    final root = json['bid'] is Map<String, dynamic>
        ? json['bid'] as Map<String, dynamic>
        : json;

    final amountRaw = root['amount'];
    final num amount = amountRaw is num
        ? amountRaw
        : num.tryParse(amountRaw?.toString() ?? '') ?? 0;

    final nestedWorker = root['worker'];
    String workerFromNested = '';
    if (nestedWorker is Map<String, dynamic>) {
      workerFromNested = (nestedWorker['id'] ?? nestedWorker['_id'] ?? '')
          .toString();
    }
    return OpenJobPostBid(
      id: (root['id'] ?? root['_id'] ?? '').toString(),
      workerId: (root['workerId'] ??
              root['worker_id'] ??
              workerFromNested)
          .toString(),
      amount: amount,
      currency: (root['currency'] ?? 'PKR').toString(),
      note: (root['note'] ?? '').toString(),
      status: OpenJobPostBidStatus.fromRaw(root['status'] as String?),
      createdAt: _parseDate(root['createdAt']),
      updatedAt: _parseDate(root['updatedAt']),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}
