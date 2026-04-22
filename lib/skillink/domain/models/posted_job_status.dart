enum PostedJobStatus {
  open,
  inProgress,
  completed,
  cancelled,
}

extension PostedJobStatusX on PostedJobStatus {
  String get wireName => name;

  String get displayLabel => switch (this) {
        PostedJobStatus.open => 'Open',
        PostedJobStatus.inProgress => 'In progress',
        PostedJobStatus.completed => 'Completed',
        PostedJobStatus.cancelled => 'Cancelled',
      };

  static PostedJobStatus parse(String? raw) {
    if (raw == null || raw.isEmpty) return PostedJobStatus.open;
    return PostedJobStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => PostedJobStatus.open,
    );
  }
}
