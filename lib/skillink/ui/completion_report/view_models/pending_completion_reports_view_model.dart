import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/completion_report_repository.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

final pendingCompletionReportsProvider =
    StreamProvider<List<PendingCompletionReport>>((ref) {
  final auth = ref.watch(authViewModelProvider);
  if (auth.bootstrapping || !auth.isAuthenticated) {
    return Stream.value(const <PendingCompletionReport>[]);
  }
  final repo = ref.watch(completionReportRepositoryProvider);
  final acked = ref.watch(acknowledgedCompletionReportsProvider);
  return repo
      .watchPendingForUser(
        userId: auth.user!.id,
        role: auth.user!.role,
      )
      .map(
        (list) => list.where((p) => !acked.contains(p.jobId)).toList(),
      );
});

class _AcknowledgedCompletionReports extends StateNotifier<Set<String>> {
  _AcknowledgedCompletionReports() : super(<String>{});

  void acknowledge(String jobId) {
    if (state.contains(jobId)) return;
    state = {...state, jobId};
  }
}

final acknowledgedCompletionReportsProvider = StateNotifierProvider<
    _AcknowledgedCompletionReports, Set<String>>(
  (_) => _AcknowledgedCompletionReports(),
);

final oldestPendingCompletionReportProvider =
    Provider<PendingCompletionReport?>((ref) {
  final list = ref.watch(pendingCompletionReportsProvider).valueOrNull;
  if (list == null || list.isEmpty) return null;
  final acked = ref.watch(acknowledgedCompletionReportsProvider);
  for (final p in list) {
    if (!acked.contains(p.jobId)) return p;
  }
  return null;
});
