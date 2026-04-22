class TimecoinTransaction {
  final String id;
  final String type;
  final int amount;
  final String description;
  final DateTime timestamp;
  final String? relatedUserId;

  TimecoinTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    this.relatedUserId,
  });
}
