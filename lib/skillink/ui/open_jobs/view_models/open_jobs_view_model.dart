import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/job_post_tag.dart';
import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/domain/models/posted_job_status.dart';

class OpenJobRow {
  const OpenJobRow({
    required this.job,
    required this.bidCount,
    required this.distanceKm,
  });

  final PostedJob job;
  final int bidCount;
  final double distanceKm;
}

class OpenJobsState {
  const OpenJobsState({
    this.rows = const <OpenJobRow>[],
    this.isLoading = true,
    this.errorMessage,
  });

  final List<OpenJobRow> rows;
  final bool isLoading;
  final String? errorMessage;
}

class OpenJobsViewModel extends StateNotifier<OpenJobsState> {
  OpenJobsViewModel(this._ref) : super(const OpenJobsState()) {
    _init();
  }

  final Ref _ref;
  StreamSubscription<List<PostedJob>>? _postedSub;
  int _generation = 0;
  DateTime _positionFetchedAt = DateTime.fromMillisecondsSinceEpoch(0);
  Position? _cachedPosition;

  Future<void> _init() async {
    final wr = _ref.read(workerRepositoryProvider);
    final prof = await wr.getMyProfile();
    if (!mounted) return;
    if (prof.isFailure) {
      state = OpenJobsState(
        isLoading: false,
        errorMessage: prof.errorOrNull ?? 'Could not load profile.',
      );
      return;
    }
    final worker = prof.valueOrNull!;
    final tags = worker.skillTypes.map(JobPostTagX.parse).toSet().toList();
    if (tags.isEmpty) {
      state = const OpenJobsState(isLoading: false);
      return;
    }
    _postedSub =
        _ref.read(postedJobRepositoryProvider).watchOpenPostedJobsForTags(tags).listen((
      jobs,
    ) {
      unawaited(_onPostedJobsEmitted(jobs, ++_generation));
    });
  }

  Future<Position?> _resolvePosition() async {
    final now = DateTime.now();
    if (_cachedPosition != null &&
        now.difference(_positionFetchedAt) < AppConstants.postedJobETARefreshInterval) {
      return _cachedPosition;
    }
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        _cachedPosition = last;
        _positionFetchedAt = now;
        return last;
      }
    } on Exception {
    }
    try {
      final pos = await Geolocator.getCurrentPosition();
      _cachedPosition = pos;
      _positionFetchedAt = now;
      return pos;
    } on Exception {
      return _cachedPosition;
    }
  }

  Future<void> _onPostedJobsEmitted(List<PostedJob> jobs, int gen) async {
    if (!mounted || gen != _generation) return;
    final pos = await _resolvePosition();
    if (!mounted || gen != _generation) return;

    final open = jobs.where((j) => j.status == PostedJobStatus.open).toList();
    final bidsRepo = _ref.read(postedJobBidRepositoryProvider);
    final rows = <OpenJobRow>[];

    for (final j in open) {
      if (!mounted || gen != _generation) return;
      final countRes = await bidsRepo.countNonWithdrawnBidsForJob(j.jobId);
      final count = countRes.isSuccess ? (countRes.valueOrNull ?? 0) : 0;
      var km = 0.0;
      if (pos != null) {
        km = Geolocator.distanceBetween(
              pos.latitude,
              pos.longitude,
              j.locationLat,
              j.locationLng,
            ) /
            1000;
      }
      rows.add(OpenJobRow(job: j, bidCount: count, distanceKm: km));
    }
    if (!mounted || gen != _generation) return;
    state = OpenJobsState(rows: rows, isLoading: false);
  }

  @override
  void dispose() {
    _postedSub?.cancel();
    super.dispose();
  }
}

final openJobsViewModelProvider =
    StateNotifierProvider.autoDispose<OpenJobsViewModel, OpenJobsState>((ref) {
  return OpenJobsViewModel(ref);
});
