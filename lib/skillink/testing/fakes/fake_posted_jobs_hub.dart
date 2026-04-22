import 'dart:async';
import 'dart:math' as math;

import 'package:skilllink/skillink/data/repositories/job_repository.dart';
import 'package:skilllink/skillink/data/repositories/posted_job_bid_repository.dart';
import 'package:skilllink/skillink/data/repositories/posted_job_repository.dart';
import 'package:skilllink/skillink/data/repositories/posted_jobs_hub.dart';
import 'package:skilllink/skillink/data/services/local_notifications_service.dart';
import 'package:skilllink/skillink/domain/models/job_post_tag.dart';
import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/domain/models/posted_job_bid.dart';
import 'package:skilllink/skillink/domain/models/posted_job_status.dart';
import 'package:skilllink/skillink/testing/models/sample_workers.dart';
import 'package:skilllink/skillink/utils/result.dart';

class FakePostedJobsHub implements PostedJobsHub {
  FakePostedJobsHub({
    required JobRepository jobRepository,
    required LocalNotificationsService notifications,
    this.autoSeedBids = true,
    this.currentUserId,
  })  : _jobRepository = jobRepository,
        _notifications = notifications;

  final bool autoSeedBids;

  final String? Function()? currentUserId;

  final JobRepository _jobRepository;
  final LocalNotificationsService _notifications;

  static const _latency = Duration(milliseconds: 280);

  final Map<String, PostedJob> _jobs = {};
  final Map<String, Map<String, PostedJobBid>> _bidsByJob = {};

  final Map<String, Future<Result<PostedJob>>> _acceptInFlight = {};

  final Map<String, List<StreamController<PostedJob?>>> _jobWatchers = {};
  final List<({String uid, StreamController<List<PostedJob>> ctrl})>
      _myPostedWatchers = [];
  final List<({_TagsKey key, StreamController<List<PostedJob>> ctrl})>
      _openWatchers = [];
  final List<({String workerId, StreamController<List<PostedJobBid>> ctrl})>
      _workerBidWatchers = [];

  int _idSeq = 0;

  void _notifyIfNotActor({
    required String? actorId,
    required String title,
    required String body,
    required String payload,
  }) {
    final me = currentUserId?.call();
    if (me != null && actorId != null && me == actorId) return;
    unawaited(
      _notifications.showPostedJobsAlert(
        title: title,
        body: body,
        payload: payload,
      ),
    );
  }

  void dispose() {
    for (final list in _jobWatchers.values) {
      for (final c in list) {
        unawaited(c.close());
      }
    }
    _jobWatchers.clear();
    for (final w in _myPostedWatchers) {
      unawaited(w.ctrl.close());
    }
    _myPostedWatchers.clear();
    for (final w in _openWatchers) {
      unawaited(w.ctrl.close());
    }
    _openWatchers.clear();
    for (final w in _workerBidWatchers) {
      unawaited(w.ctrl.close());
    }
    _workerBidWatchers.clear();
  }

  void _emitJob(String jobId) {
    final j = _jobs[jobId];
    for (final c in _jobWatchers[jobId] ?? const <StreamController<PostedJob?>>[]) {
      if (!c.isClosed) c.add(j);
    }
    _emitMyLists();
    _emitOpenLists();
    _emitAllWorkerBidStreams();
  }

  void _emitMyLists() {
    for (final w in _myPostedWatchers) {
      if (w.ctrl.isClosed) continue;
      final list = _jobs.values
          .where((j) => j.homeownerId == w.uid)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      w.ctrl.add(list);
    }
  }

  void _emitOpenLists() {
    for (final w in _openWatchers) {
      if (w.ctrl.isClosed) continue;
      w.ctrl.add(_openJobsForTags(w.key.tags));
    }
  }

  void _emitAllWorkerBidStreams() {
    for (final w in _workerBidWatchers) {
      if (w.ctrl.isClosed) continue;
      final list = <PostedJobBid>[];
      for (final m in _bidsByJob.values) {
        for (final b in m.values) {
          if (b.workerId == w.workerId) list.add(b);
        }
      }
      list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      w.ctrl.add(list);
    }
  }

  List<PostedJob> _openJobsForTags(List<JobPostTag> tags) {
    if (tags.isEmpty) return const <PostedJob>[];
    final tagSet = tags.map((t) => t.wireName).toSet();
    final list = _jobs.values
        .where(
          (j) =>
              j.status == PostedJobStatus.open && tagSet.contains(j.tag.wireName),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }


  @override
  Future<Result<String>> createPostedJob(CreatePostedJobPayload payload) async {
    await Future<void>.delayed(_latency);
    _idSeq += 1;
    final id = 'post_${DateTime.now().millisecondsSinceEpoch}_$_idSeq';
    final job = PostedJob(
      jobId: id,
      homeownerId: payload.homeownerId,
      title: payload.title,
      tag: payload.tag,
      descriptionText: payload.descriptionText,
      descriptionVoiceUrl: payload.descriptionVoiceUrl,
      media: payload.media,
      location: payload.location,
      locationLat: payload.locationLat,
      locationLng: payload.locationLng,
      status: PostedJobStatus.open,
      createdAt: DateTime.now(),
      homeownerDisplayName: payload.homeownerDisplayName,
    );
    _jobs[id] = job;
    _bidsByJob[id] = {};
    _emitJob(id);
    _notifyIfNotActor(
      actorId: payload.homeownerId,
      title: 'New job posted',
      body: payload.title,
      payload: 'posted_job:$id',
    );
    if (autoSeedBids) unawaited(_seedDummyBids(id));
    return Success(id);
  }

  final math.Random _rng = math.Random();

  Future<void> _seedDummyBids(String jobId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final job = _jobs[jobId];
    if (job == null || job.status != PostedJobStatus.open) return;

    final tagSlug = job.tag.serviceTypeSlug;
    final pool = SampleWorkers.all
        .where((w) => w.skillTypes.contains(tagSlug))
        .toList();
    final workers = pool.isNotEmpty ? pool : SampleWorkers.all;

    final wantedCount = 2 + _rng.nextInt(2);
    final count = wantedCount > workers.length ? workers.length : wantedCount;
    if (count == 0) return;
    final shuffled = List.of(workers)..shuffle(_rng);
    final bidders = shuffled.take(count);

    final bids = _bidsByJob.putIfAbsent(jobId, () => <String, PostedJobBid>{});
    final base = DateTime.now();
    var offset = 0;
    for (final w in bidders) {
      _idSeq += 1;
      final bidId = 'bid_seed_$_idSeq';
      final visiting = 300.0 + _rng.nextInt(700);
      final estimate = 1000.0 + _rng.nextInt(4000);
      final eta = 10 + _rng.nextInt(50);
      final submittedAt = base.add(Duration(milliseconds: offset));
      offset += 5;
      bids[bidId] = PostedJobBid(
        bidId: bidId,
        jobId: jobId,
        workerId: w.id,
        offeredBy: PostedBidOfferedBy.worker,
        visitingCharges: visiting,
        jobChargesEstimate: estimate,
        note: _randomNote(),
        etaMinutes: eta,
        submittedAt: submittedAt,
        status: PostedBidStatus.pending,
      );
    }
    _emitJob(jobId);
  }

  String? _randomNote() {
    const notes = [
      'I can start right away.',
      'Available this week, flexible on timing.',
      'Have done similar jobs before — happy to help.',
      null,
      null,
    ];
    return notes[_rng.nextInt(notes.length)];
  }

  @override
  Future<Result<void>> updatePostedJob(PostedJob job) async {
    await Future<void>.delayed(_latency);
    if (!_jobs.containsKey(job.jobId)) {
      return const Failure('Posted job not found.');
    }
    if (_jobs[job.jobId]!.homeownerId != job.homeownerId) {
      return const Failure('Not allowed.');
    }
    final existing = _jobs[job.jobId]!;
    final accepted = existing.acceptedBidId != null;
    if (accepted && (job.title != existing.title || job.tag != existing.tag)) {
      return const Failure('Cannot edit job after a bid is accepted.');
    }
    _jobs[job.jobId] = job;
    _emitJob(job.jobId);
    return const Success(null);
  }

  @override
  Future<Result<void>> softDeletePostedJob({
    required String jobId,
    required String homeownerId,
  }) async {
    await Future<void>.delayed(_latency);
    final j = _jobs[jobId];
    if (j == null) return const Failure('Posted job not found.');
    if (j.homeownerId != homeownerId) return const Failure('Not allowed.');
    if (j.acceptedBidId != null) {
      return const Failure('Cannot delete after accepting a bid.');
    }
    final cancelled = j.copyWith(status: PostedJobStatus.cancelled);
    _jobs[jobId] = cancelled;
    for (final bid in _bidsByJob[jobId]?.values ?? const <PostedJobBid>[]) {
      if (bid.status == PostedBidStatus.pending) {
        _bidsByJob[jobId]![bid.bidId] =
            bid.copyWith(status: PostedBidStatus.rejected);
      }
    }
    _emitJob(jobId);
    return const Success(null);
  }

  @override
  Stream<PostedJob?> watchPostedJob(String jobId) {
    final c = StreamController<PostedJob?>.broadcast();
    final list = _jobWatchers.putIfAbsent(jobId, () => <StreamController<PostedJob?>>[]);
    list.add(c);
    scheduleMicrotask(() => c.add(_jobs[jobId]));
    c.onCancel = () {
      list.remove(c);
      if (list.isEmpty) _jobWatchers.remove(jobId);
    };
    return c.stream;
  }

  @override
  Stream<List<PostedJob>> watchMyPostedJobs(String homeownerId) {
    final c = StreamController<List<PostedJob>>.broadcast();
    _myPostedWatchers.add((uid: homeownerId, ctrl: c));
    scheduleMicrotask(() {
      final initial =
          _jobs.values.where((j) => j.homeownerId == homeownerId).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      c.add(initial);
    });
    c.onCancel = () {
      _myPostedWatchers.removeWhere((w) => w.ctrl == c);
    };
    return c.stream;
  }

  @override
  Stream<List<PostedJob>> watchOpenPostedJobsForTags(List<JobPostTag> tags) {
    final c = StreamController<List<PostedJob>>.broadcast();
    final key = _TagsKey(tags);
    _openWatchers.add((key: key, ctrl: c));
    scheduleMicrotask(() => c.add(_openJobsForTags(tags)));
    c.onCancel = () {
      _openWatchers.removeWhere((w) => w.ctrl == c);
    };
    return c.stream;
  }


  @override
  Stream<List<PostedJobBid>> watchBidsForJob(String jobId) {
    late final StreamController<List<PostedJobBid>> c;
    late final StreamSubscription<PostedJob?> sub;
    void push() {
      final m = _bidsByJob[jobId];
      if (m == null) {
        if (!c.isClosed) c.add(const <PostedJobBid>[]);
        return;
      }
      final list = m.values.toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      if (!c.isClosed) c.add(list);
    }

    c = StreamController<List<PostedJobBid>>.broadcast(
      onCancel: () => sub.cancel(),
    );
    scheduleMicrotask(push);
    sub = watchPostedJob(jobId).listen((_) => push());
    return c.stream;
  }

  @override
  Future<Result<int>> countNonWithdrawnBidsForJob(String jobId) async {
    await Future<void>.delayed(_latency);
    final m = _bidsByJob[jobId];
    if (m == null) return const Success(0);
    final n = m.values.where((b) => b.status != PostedBidStatus.withdrawn).length;
    return Success(n);
  }

  @override
  Stream<List<PostedJobBid>> watchBidsForWorker(String workerId) {
    final c = StreamController<List<PostedJobBid>>.broadcast();
    _workerBidWatchers.add((workerId: workerId, ctrl: c));
    scheduleMicrotask(_emitAllWorkerBidStreams);
    c.onCancel = () {
      _workerBidWatchers.removeWhere((w) => w.ctrl == c);
    };
    return c.stream;
  }

  @override
  Future<Result<String>> submitWorkerBid({
    required String jobId,
    required String workerId,
    required double visitingCharges,
    required double jobChargesEstimate,
    required int etaMinutes,
    String? note,
  }) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return const Failure('Job not found.');
    if (job.status != PostedJobStatus.open) {
      return const Failure('This job is no longer open for bids.');
    }
    final bids = _bidsByJob.putIfAbsent(jobId, () => <String, PostedJobBid>{});
    for (final e in bids.entries) {
      final b = e.value;
      if (b.offeredBy == PostedBidOfferedBy.worker &&
          b.workerId == workerId &&
          b.status == PostedBidStatus.pending) {
        bids[e.key] = b.copyWith(status: PostedBidStatus.withdrawn);
      }
    }
    _idSeq += 1;
    final bidId = 'bid_${DateTime.now().microsecondsSinceEpoch}_$_idSeq';
    bids[bidId] = PostedJobBid(
      bidId: bidId,
      jobId: jobId,
      workerId: workerId,
      offeredBy: PostedBidOfferedBy.worker,
      visitingCharges: visitingCharges,
      jobChargesEstimate: jobChargesEstimate,
      note: note,
      etaMinutes: etaMinutes,
      submittedAt: DateTime.now(),
      status: PostedBidStatus.pending,
    );
    _emitJob(jobId);
    _notifyIfNotActor(
      actorId: workerId,
      title: 'New bid on your post',
      body: job.title,
      payload: 'posted_bid:$jobId',
    );
    return Success(bidId);
  }

  @override
  Future<Result<void>> withdrawBid({
    required String jobId,
    required String bidId,
    required String workerId,
  }) async {
    await Future<void>.delayed(_latency);
    final bids = _bidsByJob[jobId];
    final b = bids?[bidId];
    if (b == null) return const Failure('Bid not found.');
    if (b.workerId != workerId) return const Failure('Not your bid.');
    if (b.status != PostedBidStatus.pending) {
      return const Failure('Only pending bids can be withdrawn.');
    }
    bids![bidId] = b.copyWith(status: PostedBidStatus.withdrawn);
    _emitJob(jobId);
    return const Success(null);
  }

  @override
  Future<Result<void>> homeownerRejectBid({
    required String jobId,
    required String bidId,
    required String homeownerId,
  }) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return const Failure('Job not found.');
    if (job.homeownerId != homeownerId) return const Failure('Not allowed.');
    final bids = _bidsByJob[jobId];
    final b = bids?[bidId];
    if (b == null) return const Failure('Bid not found.');
    if (b.status != PostedBidStatus.pending) {
      return const Failure('Bid is not pending.');
    }
    bids![bidId] = b.copyWith(status: PostedBidStatus.rejected);
    _emitJob(jobId);
    _notifyIfNotActor(
      actorId: homeownerId,
      title: 'Bid update',
      body: 'A bid on "${job.title}" was rejected.',
      payload: 'posted_bid:$jobId',
    );
    return const Success(null);
  }

  @override
  Future<Result<PostedJob>> homeownerAcceptBid({
    required String jobId,
    required String bidId,
    required String homeownerId,
  }) {
    final pending = _acceptInFlight[jobId];
    if (pending != null) return pending;
    final fut = _doHomeownerAcceptBid(
      jobId: jobId,
      bidId: bidId,
      homeownerId: homeownerId,
    );
    _acceptInFlight[jobId] = fut;
    fut.whenComplete(() => _acceptInFlight.remove(jobId));
    return fut;
  }

  Future<Result<PostedJob>> _doHomeownerAcceptBid({
    required String jobId,
    required String bidId,
    required String homeownerId,
  }) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return const Failure('Job not found.');
    if (job.homeownerId != homeownerId) return const Failure('Not allowed.');
    if (job.status != PostedJobStatus.open) {
      return const Failure('Job is not open.');
    }
    final bids = _bidsByJob[jobId];
    final selected = bids?[bidId];
    if (selected == null) return const Failure('Bid not found.');
    if (selected.status != PostedBidStatus.pending ||
        selected.offeredBy != PostedBidOfferedBy.worker) {
      return const Failure('Invalid bid to accept.');
    }
    final workerId = selected.workerId;
    if (workerId == null || workerId.isEmpty) {
      return const Failure('Bid has no worker.');
    }

    final desc = job.descriptionText?.trim().isNotEmpty == true
        ? job.descriptionText!.trim()
        : (job.title);
    final scheduled = DateTime.now().add(const Duration(days: 1));
    final handoff = await _jobRepository.createJobFromPostedAcceptance(
      postedJobId: jobId,
      homeownerId: homeownerId,
      workerId: workerId,
      serviceType: job.tag.serviceTypeSlug,
      description: desc,
      address: job.location,
      visitingCharges: selected.visitingCharges,
      jobChargesEstimate: selected.jobChargesEstimate,
      scheduledDate: scheduled,
    );
    if (handoff.isFailure) {
      return Failure(handoff.errorOrNull ?? 'Could not start tracking job.');
    }
    final tracking = handoff.valueOrNull!;

    for (final e in bids!.entries) {
      if (e.key == bidId) continue;
      if (e.value.status == PostedBidStatus.pending) {
        bids[e.key] = e.value.copyWith(status: PostedBidStatus.rejected);
      }
    }
    bids[bidId] = selected.copyWith(status: PostedBidStatus.accepted);

    final updated = job.copyWith(
      status: PostedJobStatus.inProgress,
      acceptedBidId: bidId,
      acceptedWorkerId: workerId,
      acceptedAt: DateTime.now(),
      trackingJobId: tracking.jobId,
    );
    _jobs[jobId] = updated;
    _emitJob(jobId);
    _notifyIfNotActor(
      actorId: homeownerId,
      title: 'Your bid was accepted',
      body: job.title,
      payload: 'posted_accept:$jobId',
    );
    return Success(updated);
  }

  @override
  Future<Result<void>> homeownerCounterOffer({
    required String jobId,
    required String homeownerId,
    required double visitingCharges,
    required double jobChargesEstimate,
    String? note,
  }) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return const Failure('Job not found.');
    if (job.homeownerId != homeownerId) return const Failure('Not allowed.');
    if (job.status != PostedJobStatus.open) {
      return const Failure('Job is not open.');
    }
    _idSeq += 1;
    final bidId = 'counter_${DateTime.now().microsecondsSinceEpoch}_$_idSeq';
    final bids = _bidsByJob.putIfAbsent(jobId, () => <String, PostedJobBid>{});
    bids[bidId] = PostedJobBid(
      bidId: bidId,
      jobId: jobId,
      workerId: null,
      offeredBy: PostedBidOfferedBy.homeowner,
      visitingCharges: visitingCharges,
      jobChargesEstimate: jobChargesEstimate,
      note: note,
      etaMinutes: 0,
      submittedAt: DateTime.now(),
      status: PostedBidStatus.pending,
    );
    _emitJob(jobId);
    _notifyIfNotActor(
      actorId: homeownerId,
      title: 'Counter-offer sent',
      body: job.title,
      payload: 'posted_counter:$jobId',
    );
    return const Success(null);
  }

  @override
  Future<Result<PostedJob>> workerAcceptCounterOffer({
    required String jobId,
    required String counterBidId,
    required String workerId,
  }) {
    final pending = _acceptInFlight[jobId];
    if (pending != null) return pending;
    final fut = _doWorkerAcceptCounterOffer(
      jobId: jobId,
      counterBidId: counterBidId,
      workerId: workerId,
    );
    _acceptInFlight[jobId] = fut;
    fut.whenComplete(() => _acceptInFlight.remove(jobId));
    return fut;
  }

  Future<Result<PostedJob>> _doWorkerAcceptCounterOffer({
    required String jobId,
    required String counterBidId,
    required String workerId,
  }) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return const Failure('Job not found.');
    if (job.status != PostedJobStatus.open) {
      return const Failure('Job is no longer open.');
    }
    final bids = _bidsByJob[jobId];
    final counter = bids?[counterBidId];
    if (counter == null) return const Failure('Counter-offer not found.');
    if (counter.offeredBy != PostedBidOfferedBy.homeowner) {
      return const Failure('That bid is not a counter-offer.');
    }
    if (counter.status != PostedBidStatus.pending) {
      return const Failure('Counter-offer is no longer pending.');
    }

    final desc = job.descriptionText?.trim().isNotEmpty == true
        ? job.descriptionText!.trim()
        : job.title;
    final scheduled = DateTime.now().add(const Duration(days: 1));
    final handoff = await _jobRepository.createJobFromPostedAcceptance(
      postedJobId: jobId,
      homeownerId: job.homeownerId,
      workerId: workerId,
      serviceType: job.tag.serviceTypeSlug,
      description: desc,
      address: job.location,
      visitingCharges: counter.visitingCharges,
      jobChargesEstimate: counter.jobChargesEstimate,
      scheduledDate: scheduled,
    );
    if (handoff.isFailure) {
      return Failure(handoff.errorOrNull ?? 'Could not start tracking job.');
    }
    final tracking = handoff.valueOrNull!;

    for (final e in bids!.entries) {
      if (e.key == counterBidId) continue;
      if (e.value.status == PostedBidStatus.pending) {
        bids[e.key] = e.value.copyWith(status: PostedBidStatus.rejected);
      }
    }
    bids[counterBidId] = counter.copyWith(status: PostedBidStatus.accepted);

    final updated = job.copyWith(
      status: PostedJobStatus.inProgress,
      acceptedBidId: counterBidId,
      acceptedWorkerId: workerId,
      acceptedAt: DateTime.now(),
      trackingJobId: tracking.jobId,
    );
    _jobs[jobId] = updated;
    _emitJob(jobId);
    _notifyIfNotActor(
      actorId: workerId,
      title: 'Counter-offer accepted',
      body: 'A worker accepted your counter-offer on "${job.title}".',
      payload: 'posted_accept:$jobId',
    );
    return Success(updated);
  }

  @override
  Future<Result<void>> workerRejectCounterOffer({
    required String jobId,
    required String counterBidId,
    required String workerId,
  }) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return const Failure('Job not found.');
    final bids = _bidsByJob[jobId];
    final counter = bids?[counterBidId];
    if (counter == null) return const Failure('Counter-offer not found.');
    if (counter.offeredBy != PostedBidOfferedBy.homeowner) {
      return const Failure('That bid is not a counter-offer.');
    }
    if (counter.status != PostedBidStatus.pending) {
      return const Failure('Counter-offer is no longer pending.');
    }
    bids![counterBidId] = counter.copyWith(status: PostedBidStatus.rejected);
    _emitJob(jobId);
    _notifyIfNotActor(
      actorId: workerId,
      title: 'Counter-offer declined',
      body: 'A worker declined your counter-offer on "${job.title}".',
      payload: 'posted_counter:$jobId',
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> homeownerWithdrawCounterOffer({
    required String jobId,
    required String bidId,
    required String homeownerId,
  }) async {
    await Future<void>.delayed(_latency);
    final job = _jobs[jobId];
    if (job == null) return const Failure('Job not found.');
    if (job.homeownerId != homeownerId) return const Failure('Not allowed.');
    final bids = _bidsByJob[jobId];
    final b = bids?[bidId];
    if (b == null) return const Failure('Counter-offer not found.');
    if (b.offeredBy != PostedBidOfferedBy.homeowner) {
      return const Failure('Not your counter-offer.');
    }
    if (b.status != PostedBidStatus.pending) {
      return const Failure('Only pending counter-offers can be withdrawn.');
    }
    bids![bidId] = b.copyWith(status: PostedBidStatus.withdrawn);
    _emitJob(jobId);
    return const Success(null);
  }
}

class _TagsKey {
  _TagsKey(List<JobPostTag> input)
      : tags = List<JobPostTag>.unmodifiable(
          List<JobPostTag>.from(input)
            ..sort((a, b) => a.name.compareTo(b.name)),
        ),
        key = (List<String>.from(input.map((t) => t.wireName))..sort()).join('|');

  final List<JobPostTag> tags;
  final String key;

  @override
  bool operator ==(Object other) => other is _TagsKey && other.key == key;

  @override
  int get hashCode => key.hashCode;
}
