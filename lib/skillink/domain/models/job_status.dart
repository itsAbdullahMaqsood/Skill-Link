enum JobStatus {
  posted,
  workerAccepted,
  bidReceived,
  bidAccepted,
  onTheWay,
  arrived,
  inProgress,
  completed,
  cancelledNoPenalty,
  cancelledWithPenalty;

  String get displayName => switch (this) {
    JobStatus.posted => 'Posted',
    JobStatus.workerAccepted => 'Worker Interested',
    JobStatus.bidReceived => 'Bid Received',
    JobStatus.bidAccepted => 'Bid Accepted',
    JobStatus.onTheWay => 'On The Way',
    JobStatus.arrived => 'Arrived',
    JobStatus.inProgress => 'In Progress',
    JobStatus.completed => 'Completed',
    JobStatus.cancelledNoPenalty => 'Cancelled',
    JobStatus.cancelledWithPenalty => 'Cancelled (Penalty)',
  };

  bool get isCancelled =>
      this == JobStatus.cancelledNoPenalty ||
      this == JobStatus.cancelledWithPenalty;

  bool get isActive => !isCancelled && this != JobStatus.completed;
}
