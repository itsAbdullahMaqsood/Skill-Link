import 'dart:async';
import 'dart:math' as math;

import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/repositories/job_repository.dart';
import 'package:skilllink/skillink/domain/models/bid.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/payment_method.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/testing/models/sample_jobs.dart';
import 'package:skilllink/skillink/utils/result.dart';

class FakeJobRepository implements JobRepository {
  FakeJobRepository({List<Job>? seed, math.Random? rng})
      : _rng = rng ?? math.Random(),
        _jobs = {
          for (final j in (seed ??
              [
                ...SampleJobs.recentJobs,
                if (AppConstants.seedDemoCompletionReport)
                  SampleJobs.demoCompletedAwaitingReport,
              ]))
            j.jobId: j,
        };

  final math.Random _rng;
  final Map<String, Job> _jobs;
  final Map<String, StreamController<Job>> _jobStreams = {};
  final Map<String, StreamController<({double lat, double lng})>>
      _locStreams = {};
  final Map<String, List<Timer>> _timers = {};
  final Map<String, Timer> _locationTimers = {};

  final StreamController<void> _changes = StreamController<void>.broadcast();
  Stream<void> get jobsChanged => _changes.stream;
  void _notifyChange() {
    if (!_changes.isClosed) _changes.add(null);
  }

  static const _latency = Duration(milliseconds: 250);

  bool failNextCreateJobFromPostedAcceptance = false;


  @override
  Future<Result<Job?>> getActiveJob() async {
    await Future<void>.delayed(_latency);
    final active = _jobs.values
        .where(
          (j) =>
              j.status.isActive &&
              !(j.status == JobStatus.posted && j.workerId == null),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(active.isEmpty ? null : active.first);
  }

  @override
  Future<Result<List<Job>>> getRecentJobs({int limit = 10}) async {
    await Future<void>.delayed(_latency);
    final sorted = _jobs.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(sorted.take(limit).toList());
  }

  @override
  Future<Result<List<Job>>> listJobs() async {
    await Future<void>.delayed(_latency);
    final sorted = _jobs.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(sorted);
  }

  @override
  Future<Result<Job>> getJob(String jobId) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return Failure('Job not found.');
    return Success(job);
  }


  @override
  Future<Result<Job>> createJob(CreateJobInput input) async {
    await Future<void>.delayed(_latency);
    final now = DateTime.now();
    final id = 'job_${now.microsecondsSinceEpoch}';

    final job = Job(
      jobId: id,
      userId: 'homeowner_001',
      workerId: input.workerId,
      serviceType: input.serviceType,
      status: JobStatus.posted,
      scheduledDate: input.scheduledDate,
      description: input.description,
      photoUrls: input.localPhotoPaths,
      address: input.address,
      paymentMethod: input.paymentMethod == PaymentMethodInput.inApp
          ? PaymentMethod.inApp
          : PaymentMethod.cash,
      createdAt: now,
    );

    _jobs[id] = job;
    _emit(id, job);

    _schedule(id, const Duration(milliseconds: 1500), () {
      _advance(id, (j) => j.copyWith(status: JobStatus.workerAccepted));
    });

    _schedule(id, const Duration(milliseconds: 3000), () {
      _advance(id, (j) {
        final suggested = _suggestPrice(j.serviceType);
        return j.copyWith(
          status: JobStatus.bidReceived,
          bidHistory: [
            ...j.bidHistory,
            Bid(
              bidId: 'bid_${DateTime.now().microsecondsSinceEpoch}',
              bidderId: j.workerId ?? 'w_unknown',
              amount: suggested,
              submittedAt: DateTime.now(),
            ),
          ],
        );
      });
    });

    return Success(job);
  }

  @override
  Future<Result<Job>> createJobFromPostedAcceptance({
    required String postedJobId,
    required String homeownerId,
    required String workerId,
    required String serviceType,
    required String description,
    required StructuredAddress address,
    required double visitingCharges,
    required double jobChargesEstimate,
    required DateTime scheduledDate,
  }) async {
    await Future<void>.delayed(_latency);
    if (failNextCreateJobFromPostedAcceptance) {
      failNextCreateJobFromPostedAcceptance = false;
      return const Failure('Simulated handoff failure.');
    }
    final id = 'pj_$postedJobId';
    final total = visitingCharges + jobChargesEstimate;
    final now = DateTime.now();
    final bid = Bid(
      bidId: 'posted_$postedJobId',
      bidderId: workerId,
      amount: total,
      submittedAt: now,
      accepted: true,
    );
    final job = Job(
      jobId: id,
      userId: homeownerId,
      workerId: workerId,
      serviceType: serviceType,
      status: JobStatus.bidAccepted,
      scheduledDate: scheduledDate,
      description: description,
      photoUrls: const <String>[],
      address: address,
      paymentMethod: PaymentMethod.cash,
      createdAt: now,
      finalPrice: total,
      bidHistory: <Bid>[bid],
    );
    _jobs[id] = job;
    _emit(id, job);
    _runPostAcceptTimeline(id);
    return Success(job);
  }

  @override
  Future<Result<Job>> submitBid({
    required String jobId,
    required double amount,
  }) async {
    await Future<void>.delayed(_latency);
    final base = _jobs[jobId];
    if (base == null) return Failure('Job not found.');

    final appendAsHomeowner =
        base.bidHistory.isNotEmpty && base.bidHistory.last.isFromWorker;
    const defaultWorkerId = 'w_001';
    final bidderId = appendAsHomeowner ? 'homeowner' : defaultWorkerId;
    final resolvedWorkerId =
        appendAsHomeowner ? base.workerId : (base.workerId ?? defaultWorkerId);

    final withBid = base.copyWith(
      workerId: resolvedWorkerId,
      status: JobStatus.bidReceived,
      bidHistory: [
        ...base.bidHistory,
        Bid(
          bidId: 'bid_${DateTime.now().microsecondsSinceEpoch}',
          bidderId: bidderId,
          amount: amount,
          submittedAt: DateTime.now(),
        ),
      ],
    );
    _jobs[jobId] = withBid;
    _emit(jobId, withBid);

    if (appendAsHomeowner) {
      _schedule(jobId, const Duration(milliseconds: 1800), () {
        _advance(jobId, (j) {
          final acceptsCounter = _rng.nextDouble() < 0.5;
          if (acceptsCounter) {
            return j.copyWith(
              status: JobStatus.bidReceived,
              bidHistory: [
                ...j.bidHistory,
                Bid(
                  bidId: 'bid_${DateTime.now().microsecondsSinceEpoch}',
                  bidderId: j.workerId ?? 'w_unknown',
                  amount: amount,
                  submittedAt: DateTime.now(),
                ),
              ],
            );
          }
          return j.copyWith(
            status: JobStatus.bidReceived,
            bidHistory: [
              ...j.bidHistory,
              Bid(
                bidId: 'bid_${DateTime.now().microsecondsSinceEpoch}',
                bidderId: j.workerId ?? 'w_unknown',
                amount: (amount * 1.1).roundToDouble(),
                submittedAt: DateTime.now(),
              ),
            ],
          );
        });
      });
    } else {
      _schedule(jobId, const Duration(milliseconds: 2000), () {
        final j = _jobs[jobId];
        if (j == null || j.status.isCancelled) return;
        if (j.status == JobStatus.bidAccepted) return;
        _syncAcceptLatestWorkerBid(jobId);
      });
    }

    return Success(withBid);
  }

  void _syncAcceptLatestWorkerBid(String jobId) {
    final job = _jobs[jobId];
    if (job == null || job.bidHistory.isEmpty) return;
    final idx = job.bidHistory.lastIndexWhere((b) => b.isFromWorker);
    if (idx < 0) return;
    final targetBid = job.bidHistory[idx];
    final accepted = job.copyWith(
      status: JobStatus.bidAccepted,
      finalPrice: targetBid.amount,
      bidHistory: [
        for (var i = 0; i < job.bidHistory.length; i++)
          i == idx ? job.bidHistory[i].copyWith(accepted: true) : job.bidHistory[i],
      ],
    );
    _jobs[jobId] = accepted;
    _emit(jobId, accepted);
    _cancelTimers(jobId);
    _runPostAcceptTimeline(jobId);
  }

  @override
  Future<Result<Job>> acceptBid({
    required String jobId,
    String? bidId,
  }) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return Failure('Job not found.');
    if (job.bidHistory.isEmpty) {
      return Failure('No bids to accept yet.');
    }

    final targetBid = bidId == null
        ? job.bidHistory.last
        : job.bidHistory.firstWhere(
            (b) => b.bidId == bidId,
            orElse: () => job.bidHistory.last,
          );

    final accepted = job.copyWith(
      status: JobStatus.bidAccepted,
      finalPrice: targetBid.amount,
      bidHistory: [
        for (final b in job.bidHistory)
          if (b.bidId == targetBid.bidId) b.copyWith(accepted: true) else b,
      ],
    );
    _jobs[jobId] = accepted;
    _emit(jobId, accepted);

    _runPostAcceptTimeline(jobId);

    return Success(accepted);
  }

  @override
  Future<Result<Job>> advanceJobStatus({
    required String jobId,
    required JobStatus status,
  }) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return Failure('Job not found.');
    if (!_isValidWorkerAdvance(job.status, status)) {
      return const Failure('Invalid status transition.');
    }
    _cancelTimers(jobId);
    if (status == JobStatus.onTheWay) {
      _startLocationStream(jobId);
    }
    if (status.index >= JobStatus.arrived.index) {
      _stopLocationStream(jobId);
    }
    final next = job.copyWith(status: status);
    _jobs[jobId] = next;
    _emit(jobId, next);
    return Success(next);
  }

  static bool _isValidWorkerAdvance(JobStatus from, JobStatus to) {
    return switch ((from, to)) {
      (JobStatus.bidAccepted, JobStatus.onTheWay) => true,
      (JobStatus.onTheWay, JobStatus.arrived) => true,
      (JobStatus.arrived, JobStatus.inProgress) => true,
      (JobStatus.inProgress, JobStatus.completed) => true,
      _ => false,
    };
  }

  void _runPostAcceptTimeline(String jobId) {
    _schedule(jobId, const Duration(milliseconds: 2500), () {
      _advance(jobId, (j) => j.copyWith(status: JobStatus.onTheWay));
      _startLocationStream(jobId);
    });
    _schedule(jobId, const Duration(milliseconds: 7500), () {
      _advance(jobId, (j) => j.copyWith(status: JobStatus.arrived));
      _stopLocationStream(jobId);
    });
    _schedule(jobId, const Duration(milliseconds: 9500), () {
      _advance(jobId, (j) => j.copyWith(status: JobStatus.inProgress));
    });
    _schedule(jobId, const Duration(milliseconds: 14000), () {
      _advance(jobId, (j) => j.copyWith(status: JobStatus.completed));
    });
  }


  @override
  Future<Result<CancelOutcome>> cancelJob({
    required String jobId,
    String? reason,
  }) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return Failure('Job not found.');

    final elapsed = DateTime.now().difference(job.createdAt);
    final withinGrace = elapsed <= AppConstants.cancellationGracePeriod;
    final penalty = !withinGrace;

    final cancelled = job.copyWith(
      status: penalty
          ? JobStatus.cancelledWithPenalty
          : JobStatus.cancelledNoPenalty,
    );
    _jobs[jobId] = cancelled;
    _emit(jobId, cancelled);
    _cancelTimers(jobId);
    _stopLocationStream(jobId);

    return Success(CancelOutcome(job: cancelled, penaltyApplied: penalty));
  }

  @override
  Future<Result<Job>> markAsPaid({required String jobId}) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return Failure('Job not found.');
    final updated = job.copyWith(paid: true, paidAt: DateTime.now());
    _jobs[jobId] = updated;
    _emit(jobId, updated);
    return Success(updated);
  }

  @override
  Future<Result<Review>> submitReview({
    required String jobId,
    required double rating,
    String? comment,
  }) async {
    await Future<void>.delayed(_latency);
    if (!_jobs.containsKey(jobId)) return Failure('Job not found.');
    return Success(Review(
      id: 'rev_${DateTime.now().microsecondsSinceEpoch}',
      jobId: jobId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    ));
  }


  @override
  Stream<Job> watchJob(String jobId) {
    final ctrl = _jobStreams.putIfAbsent(
      jobId,
      () => StreamController<Job>.broadcast(),
    );
    final latest = _jobs[jobId];
    if (latest != null) {
      scheduleMicrotask(() {
        if (!ctrl.isClosed) ctrl.add(latest);
      });
    }
    return ctrl.stream;
  }

  @override
  Stream<({double lat, double lng})> watchWorkerLocation(String jobId) {
    final ctrl = _locStreams.putIfAbsent(
      jobId,
      () => StreamController<({double lat, double lng})>.broadcast(),
    );
    return ctrl.stream;
  }


  void dispose() {
    for (final list in _timers.values) {
      for (final t in list) {
        t.cancel();
      }
    }
    _timers.clear();
    for (final t in _locationTimers.values) {
      t.cancel();
    }
    _locationTimers.clear();
    for (final c in _jobStreams.values) {
      c.close();
    }
    for (final c in _locStreams.values) {
      c.close();
    }
    _jobStreams.clear();
    _locStreams.clear();
    if (!_changes.isClosed) _changes.close();
  }


  void _emit(String jobId, Job job) {
    final ctrl = _jobStreams[jobId];
    if (ctrl != null && !ctrl.isClosed) ctrl.add(job);
    _notifyChange();
  }

  void _advance(String jobId, Job Function(Job) mutate) {
    final current = _jobs[jobId];
    if (current == null) return;
    final next = mutate(current);
    _jobs[jobId] = next;
    _emit(jobId, next);
  }

  void _schedule(String jobId, Duration delay, void Function() work) {
    final timer = Timer(delay, () {
      final current = _jobs[jobId];
      if (current == null || current.status.isCancelled) return;
      work();
    });
    (_timers[jobId] ??= []).add(timer);
  }

  void _cancelTimers(String jobId) {
    final list = _timers.remove(jobId);
    if (list == null) return;
    for (final t in list) {
      t.cancel();
    }
  }

  void _startLocationStream(String jobId) {
    final ctrl = _locStreams.putIfAbsent(
      jobId,
      () => StreamController<({double lat, double lng})>.broadcast(),
    );

    _locationTimers.remove(jobId)?.cancel();

    var lat = 31.5204;
    var lng = 74.3587;
    _locationTimers[jobId] = Timer.periodic(const Duration(seconds: 1), (t) {
      if (ctrl.isClosed) {
        t.cancel();
        _locationTimers.remove(jobId);
        return;
      }
      lat += 0.0005;
      lng += 0.0005;
      ctrl.add((lat: lat, lng: lng));
    });
  }

  void _stopLocationStream(String jobId) {
    _locationTimers.remove(jobId)?.cancel();
  }

  double _suggestPrice(String trade) {
    switch (trade.toLowerCase()) {
      case 'electrician':
        return 1500;
      case 'plumber':
        return 1800;
      case 'hvac':
      case 'ac':
        return 2500;
      case 'carpenter':
        return 2200;
      default:
        return 1800;
    }
  }
}
