import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/job.dart';

class JobHistoryViewModel extends StateNotifier<AsyncValue<List<Job>>> {
  JobHistoryViewModel(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    state = AsyncValue<List<Job>>.loading().copyWithPrevious(state);
    final result = await _ref.read(jobRepositoryProvider).listJobs();
    if (!mounted) return;
    result.when(
      success: (jobs) => state = AsyncValue.data(jobs),
      failure: (msg, _) =>
          state = AsyncValue.error(msg, StackTrace.current),
    );
  }

  Future<void> refresh() => _load();
}

final jobHistoryViewModelProvider =
    StateNotifierProvider.autoDispose<JobHistoryViewModel, AsyncValue<List<Job>>>(
  (ref) => JobHistoryViewModel(ref),
);
