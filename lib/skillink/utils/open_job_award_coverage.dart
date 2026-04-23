import 'package:skilllink/skillink/domain/models/open_job_post.dart';

/// Service requests created when an open-for-bids post is awarded to this worker.
/// Those rows duplicate the tracking [Job] in “In Progress” / should not appear as
/// generic “incoming” direct bookings.
Set<String> workerAwardedOpenJobServiceRequestIds(
  Iterable<OpenJobPost> posts,
  String workerUserId,
) {
  if (workerUserId.isEmpty) return {};
  final out = <String>{};
  for (final p in posts) {
    final srId = p.serviceRequestId;
    if (srId == null || srId.isEmpty) continue;
    if (p.awardedWorkerId != workerUserId) continue;
    final s = p.status;
    if (s != OpenJobPostStatus.workerSelected &&
        s != OpenJobPostStatus.awarded) {
      continue;
    }
    out.add(srId);
  }
  return out;
}
