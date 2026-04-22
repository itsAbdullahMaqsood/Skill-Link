import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';

class WorkerEarningsState {
  const WorkerEarningsState({
    this.isLoading = false,
    this.summary,
    this.errorMessage,
  });

  final bool isLoading;
  final EarningsSummary? summary;
  final String? errorMessage;

  WorkerEarningsState copyWith({
    bool? isLoading,
    EarningsSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WorkerEarningsState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class WorkerEarningsViewModel extends StateNotifier<WorkerEarningsState> {
  WorkerEarningsViewModel(this._ref)
      : super(const WorkerEarningsState(isLoading: true)) {
    refresh();
  }

  final Ref _ref;

  WorkerRepository get _workers => _ref.read(workerRepositoryProvider);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final res = await _workers.getEarnings();
    if (!mounted) return;
    res.when(
      success: (s) => state = state.copyWith(isLoading: false, summary: s),
      failure: (msg, _) => state = WorkerEarningsState(
        isLoading: false,
        summary: null,
        errorMessage: msg,
      ),
    );
  }
}

final workerEarningsViewModelProvider = StateNotifierProvider.autoDispose<
    WorkerEarningsViewModel, WorkerEarningsState>(
  (ref) => WorkerEarningsViewModel(ref),
);
