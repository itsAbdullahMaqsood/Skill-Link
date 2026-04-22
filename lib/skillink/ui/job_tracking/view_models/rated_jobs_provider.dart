import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/completion_report/view_models/pending_completion_reports_view_model.dart';

class RatedJobsTracker extends StateNotifier<Set<String>> {
  RatedJobsTracker() : super(<String>{});

  void markRated(String jobId) {
    if (state.contains(jobId)) return;
    state = {...state, jobId};
  }

  void dismiss(String jobId) => markRated(jobId);
}

final ratedJobsTrackerProvider =
    StateNotifierProvider<RatedJobsTracker, Set<String>>(
  (_) => RatedJobsTracker(),
);

final unratedCompletedJobsProvider = FutureProvider<List<Job>>((ref) async {
  final user = ref.watch(authViewModelProvider).user;
  if (user == null || user.role.name != 'homeowner') return const <Job>[];

  final pendingAsync = ref.watch(pendingCompletionReportsProvider);
  if (!pendingAsync.hasValue) return const <Job>[];
  final pendingIds = {for (final p in pendingAsync.value!) p.jobId};

  final rated = ref.watch(ratedJobsTrackerProvider);

  final jobsResult = await ref.read(jobRepositoryProvider).listJobs();
  final jobs = jobsResult.valueOrNull ?? const <Job>[];

  final ready = jobs
      .where(
        (j) =>
            j.userId == user.id &&
            j.status == JobStatus.completed &&
            j.paid &&
            !rated.contains(j.jobId) &&
            !pendingIds.contains(j.jobId),
      )
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return ready;
});

final mostRecentUnratedJobProvider = Provider<Job?>((ref) {
  return ref.watch(unratedCompletedJobsProvider).valueOrNull?.firstOrNull;
});
