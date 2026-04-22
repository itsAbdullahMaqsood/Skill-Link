import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/utils/result.dart';

class HomeownerDashboardState {
  const HomeownerDashboardState({
    this.isLoading = false,
    this.activeJob,
    this.latestAnomaly,
    this.postedJobs = const <PostedJob>[],
    this.errorMessage,
  });

  final bool isLoading;
  final Job? activeJob;
  final Anomaly? latestAnomaly;
  final List<PostedJob> postedJobs;

  final String? errorMessage;
}

class HomeownerDashboardViewModel
    extends StateNotifier<HomeownerDashboardState> {
  HomeownerDashboardViewModel(this._ref)
      : super(const HomeownerDashboardState(isLoading: true)) {
    final uid = _ref.read(authViewModelProvider).user?.id;
    if (uid != null) {
      _postedSub = _ref.read(postedJobRepositoryProvider).watchMyPostedJobs(uid).listen((
        list,
      ) {
        if (!mounted) return;
        state = HomeownerDashboardState(
          isLoading: state.isLoading,
          activeJob: state.activeJob,
          latestAnomaly: state.latestAnomaly,
          postedJobs: list.take(5).toList(),
          errorMessage: state.errorMessage,
        );
      });
    }
    refresh();
  }

  final Ref _ref;
  StreamSubscription<List<PostedJob>>? _postedSub;

  Future<void> refresh() async {
    state = HomeownerDashboardState(
      isLoading: true,
      activeJob: state.activeJob,
      latestAnomaly: state.latestAnomaly,
      postedJobs: state.postedJobs,
      errorMessage: state.errorMessage,
    );

    final jobs = _ref.read(jobRepositoryProvider);
    final anomalies = _ref.read(anomalyRepositoryProvider);

    final results = await Future.wait([
      jobs.getActiveJob(),
      anomalies.getLatestAnomaly(),
    ]);
    if (!mounted) return;

    final activeResult = results[0] as Result<Job?>;
    final anomalyResult = results[1] as Result<Anomaly?>;

    final firstError = activeResult.errorOrNull ?? anomalyResult.errorOrNull;

    state = HomeownerDashboardState(
      isLoading: false,
      activeJob: activeResult.valueOrNull,
      latestAnomaly: anomalyResult.valueOrNull,
      postedJobs: state.postedJobs,
      errorMessage: firstError,
    );
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = HomeownerDashboardState(
      isLoading: state.isLoading,
      activeJob: state.activeJob,
      latestAnomaly: state.latestAnomaly,
      postedJobs: state.postedJobs,
    );
  }

  @override
  void dispose() {
    _postedSub?.cancel();
    super.dispose();
  }
}

final homeownerDashboardViewModelProvider = StateNotifierProvider.autoDispose<
    HomeownerDashboardViewModel, HomeownerDashboardState>((ref) {
  return HomeownerDashboardViewModel(ref);
});
