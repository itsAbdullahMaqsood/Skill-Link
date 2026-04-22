import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/mappers/worker_from_skillchain_user.dart';
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/testing/models/sample_jobs.dart';
import 'package:skilllink/skillink/testing/models/sample_reviews.dart';
import 'package:skilllink/skillink/testing/models/sample_workers.dart';
import 'package:skilllink/skillink/utils/result.dart';

class FakeWorkerRepository implements WorkerRepository {
  FakeWorkerRepository({
    Worker? meOverride,
    AuthService? authService,
  })  : _me = meOverride ?? SampleWorkers.all.first,
        _auth = authService;

  Worker _me;
  final AuthService? _auth;

  static const _latency = Duration(milliseconds: 400);

  @override
  Future<Result<List<Worker>>> searchWorkers(
    WorkerSearchFilter filter,
  ) async {
    await Future<void>.delayed(_latency);

    var results = SampleWorkers.all.toList();

    if (filter.trade != null && filter.trade!.isNotEmpty) {
      final needle = filter.trade!.toLowerCase();
      results = results
          .where((w) => w.skillTypes.any((s) => s.toLowerCase() == needle))
          .toList();
    }

    if (filter.minRating != null) {
      results = results.where((w) => w.rating >= filter.minRating!).toList();
    }

    final radius = filter.radiusKm ?? AppConstants.searchResultMaxDistance;
    results = results
        .where((w) => (w.distanceKm ?? double.infinity) <= radius)
        .toList();

    switch (filter.sort) {
      case WorkerSort.ratingDesc:
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case WorkerSort.distanceAsc:
        results.sort((a, b) =>
            (a.distanceKm ?? double.infinity)
                .compareTo(b.distanceKm ?? double.infinity));
        break;
      case WorkerSort.priceAsc:
        results.sort((a, b) =>
            (a.hourlyRate ?? double.infinity)
                .compareTo(b.hourlyRate ?? double.infinity));
        break;
    }

    return Success(results);
  }

  @override
  Future<Result<Worker>> getWorker(String id) async {
    await Future<void>.delayed(_latency);
    final auth = _auth;
    if (auth != null && id.trim().isNotEmpty) {
      try {
        if (await auth.isLabourBackend()) {
          final u = await auth.getCurrentUser();
          if (u != null && u.id == id) {
            return Success(WorkerFromSkillChainUser.map(u));
          }
        }
      } catch (_) {
      }
    }
    final match = SampleWorkers.all.where((w) => w.id == id).toList();
    if (match.isEmpty) return const Failure('Worker not found.');
    return Success(match.first);
  }

  @override
  Future<Result<List<Review>>> getReviews(
    String workerId, {
    int page = 1,
  }) async {
    await Future<void>.delayed(_latency);
    return Success(SampleReviews.forWorker(workerId));
  }


  @override
  Future<Result<Worker>> getMyProfile() async {
    await Future<void>.delayed(_latency);
    final auth = _auth;
    if (auth != null) {
      try {
        if (await auth.isLabourBackend()) {
          final u = await auth.getCurrentUser();
          if (u != null) {
            final w = WorkerFromSkillChainUser.map(u);
            _me = w;
            return Success(w);
          }
        }
      } catch (_) {
      }
    }
    return Success(_me);
  }

  @override
  Future<Result<Worker>> updateProfile(WorkerProfileInput input) async {
    await Future<void>.delayed(_latency);
    _me = _me.copyWith(
      name: input.name ?? _me.name,
      phone: input.phone ?? _me.phone,
      bio: input.bio ?? _me.bio,
      hourlyRate: input.hourlyRate ?? _me.hourlyRate,
      skillTypes: input.skillTypes ?? _me.skillTypes,
      serviceRadiusKm: input.serviceRadiusKm ?? _me.serviceRadiusKm,
    );
    return Success(_me);
  }

  @override
  Future<Result<bool>> setAvailability({required bool available}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const Success(true);
  }

  @override
  Future<Result<EarningsSummary>> getEarnings() async {
    await Future<void>.delayed(_latency);
    final jobs = _seedEarningsJobs();
    final gross = jobs.fold<double>(0, (s, j) => s + j.gross);
    final fee = jobs.fold<double>(0, (s, j) => s + j.fee);
    return Success(EarningsSummary(
      thisMonthGross: gross,
      thisMonthFee: fee,
      thisMonthNet: gross - fee,
      completedJobs: jobs,
    ));
  }

  @override
  Future<Result<List<Job>>> getIncomingJobs() async {
    await Future<void>.delayed(_latency);
    return Success(SampleJobs.incomingWorkerOffers(DateTime.now()));
  }


  static List<EarningsJob> _seedEarningsJobs() {
    final now = DateTime.now();
    return [
      EarningsJob(
        jobId: 'job_past_1',
        serviceType: 'electrician',
        gross: 1800,
        fee: 180,
        net: 1620,
        completedAt: now.subtract(const Duration(days: 4)),
        paid: true,
      ),
      EarningsJob(
        jobId: 'job_past_4',
        serviceType: 'electrician',
        gross: 2200,
        fee: 220,
        net: 1980,
        completedAt: now.subtract(const Duration(days: 8)),
        paid: true,
      ),
      EarningsJob(
        jobId: 'job_past_5',
        serviceType: 'electrician',
        gross: 900,
        fee: 90,
        net: 810,
        completedAt: now.subtract(const Duration(days: 15)),
        paid: false,
      ),
    ];
  }
}
