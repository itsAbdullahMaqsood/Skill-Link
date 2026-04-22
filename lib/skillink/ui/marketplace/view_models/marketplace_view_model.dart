import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';

class MarketplaceState {
  const MarketplaceState({
    required this.filter,
    this.workers = const AsyncValue<List<Worker>>.loading(),
  });

  final WorkerSearchFilter filter;
  final AsyncValue<List<Worker>> workers;

  MarketplaceState copyWith({
    WorkerSearchFilter? filter,
    AsyncValue<List<Worker>>? workers,
  }) {
    return MarketplaceState(
      filter: filter ?? this.filter,
      workers: workers ?? this.workers,
    );
  }
}

class MarketplaceViewModel extends StateNotifier<MarketplaceState> {
  MarketplaceViewModel(this._ref, {String? initialTrade})
      : super(MarketplaceState(
          filter: WorkerSearchFilter(trade: initialTrade),
        )) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    state = state.copyWith(
      workers: const AsyncValue<List<Worker>>.loading()
          .copyWithPrevious(state.workers),
    );
    final repo = _ref.read(workerRepositoryProvider);
    Map<String, String> serviceMap = const {};
    try {
      serviceMap = await _ref.read(labourServiceIdToNameProvider.future);
    } catch (_) {}
    final filter = state.filter.copyWith(
      serviceIdToName: serviceMap.isEmpty ? null : serviceMap,
    );
    final result = await repo.searchWorkers(filter);
    if (!mounted) return;
    result.when(
      success: (workers) => state = state.copyWith(
        workers: AsyncValue.data(workers),
      ),
      failure: (message, exception) => state = state.copyWith(
        workers: AsyncValue<List<Worker>>.error(
          message,
          StackTrace.current,
        ),
      ),
    );
  }

  Future<void> refresh() => _load();

  void setTrade(String? trade) {
    if (state.filter.trade == trade) return;
    state = state.copyWith(filter: state.filter.copyWith(trade: trade));
    _load();
  }

  void setMinRating(double? minRating) {
    if (state.filter.minRating == minRating) return;
    state = state.copyWith(
      filter: state.filter.copyWith(minRating: minRating),
    );
    _load();
  }

  void setMaxDistance(double? radiusKm) {
    if (state.filter.radiusKm == radiusKm) return;
    state = state.copyWith(
      filter: state.filter.copyWith(radiusKm: radiusKm),
    );
    _load();
  }

  void setSort(WorkerSort sort) {
    if (state.filter.sort == sort) return;
    state = state.copyWith(filter: state.filter.copyWith(sort: sort));
    _load();
  }
}

final marketplaceViewModelProvider = StateNotifierProvider.autoDispose
    .family<MarketplaceViewModel, MarketplaceState, String?>(
  (ref, initialTrade) => MarketplaceViewModel(ref, initialTrade: initialTrade),
);
