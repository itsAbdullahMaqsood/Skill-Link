import 'dart:io';

import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/utils/result.dart';

/// Marketplace trade chips use slugs (`electrician`, `plumber`, …). Workers
/// may store the same slugs or opaque labour API service IDs — use
/// [serviceIdToName] from [labourServiceIdToNameProvider] when filtering.
bool workerMatchesMarketplaceTrade(
  Worker worker,
  String trade,
  Map<String, String>? serviceIdToName,
) {
  final slug = trade.trim().toLowerCase();
  if (slug.isEmpty) return true;

  bool nameMatches(String nameLower) {
    if (nameLower.isEmpty) return false;
    if (nameLower.contains(slug)) return true;
    return switch (slug) {
      'hvac' => nameLower.contains('hvac') ||
          nameLower.contains(' a/c') ||
          nameLower.contains('air cond') ||
          (nameLower.contains('ac') &&
              (nameLower.contains('repair') ||
                  nameLower.contains('servic') ||
                  nameLower.contains('split'))) ||
          nameLower.contains('cooling') ||
          nameLower.contains('heating'),
      'electrician' => nameLower.contains('electric'),
      'plumber' => nameLower.contains('plumb') || nameLower.contains('pipe'),
      'carpenter' =>
        nameLower.contains('carpent') || nameLower.contains('woodwork'),
      _ => false,
    };
  }

  String? labelForSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isEmpty) return null;
    final map = serviceIdToName;
    if (map == null || map.isEmpty) return null;
    final direct = map[trimmed] ?? map[skill];
    if (direct != null && direct.trim().isNotEmpty) return direct;
    for (final e in map.entries) {
      if (e.key.trim() == trimmed) return e.value;
    }
    return null;
  }

  for (final skill in worker.skillTypes) {
    final s = skill.trim().toLowerCase();
    if (s == slug) return true;
    if (nameMatches(s)) return true;

    final label = labelForSkill(skill)?.trim().toLowerCase() ?? '';
    if (label.isNotEmpty && nameMatches(label)) return true;
  }

  // Catalog: any service whose name matches the chip and whose id the worker has.
  final map = serviceIdToName;
  if (map != null && map.isNotEmpty) {
    final workerIds = worker.skillTypes.map((e) => e.trim()).toSet();
    for (final e in map.entries) {
      if (!workerIds.contains(e.key.trim())) continue;
      if (nameMatches(e.value.trim().toLowerCase())) return true;
    }
  }

  return false;
}

class WorkerSearchFilter {
  const WorkerSearchFilter({
    this.trade,
    this.lat,
    this.lng,
    this.radiusKm,
    this.minRating,
    this.sort = WorkerSort.ratingDesc,
    this.serviceIdToName,
  });

  final String? trade;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final double? minRating;
  final WorkerSort sort;

  /// Resolved labour service catalog; only used for client-side trade match.
  final Map<String, String>? serviceIdToName;

  WorkerSearchFilter copyWith({
    Object? trade = _sentinel,
    Object? lat = _sentinel,
    Object? lng = _sentinel,
    Object? radiusKm = _sentinel,
    Object? minRating = _sentinel,
    WorkerSort? sort,
    Object? serviceIdToName = _sentinel,
  }) {
    return WorkerSearchFilter(
      trade: trade == _sentinel ? this.trade : trade as String?,
      lat: lat == _sentinel ? this.lat : lat as double?,
      lng: lng == _sentinel ? this.lng : lng as double?,
      radiusKm: radiusKm == _sentinel ? this.radiusKm : radiusKm as double?,
      minRating:
          minRating == _sentinel ? this.minRating : minRating as double?,
      sort: sort ?? this.sort,
      serviceIdToName: serviceIdToName == _sentinel
          ? this.serviceIdToName
          : serviceIdToName as Map<String, String>?,
    );
  }

  static const _sentinel = Object();
}

enum WorkerSort {
  ratingDesc,
  distanceAsc,
  priceAsc;

  String get displayName => switch (this) {
        WorkerSort.ratingDesc => 'Top rated',
        WorkerSort.distanceAsc => 'Nearest',
        WorkerSort.priceAsc => 'Lowest price',
      };
}

abstract class WorkerRepository {
  Future<Result<List<Worker>>> searchWorkers(WorkerSearchFilter filter);

  Future<Result<Worker>> getWorker(String id);

  Future<Result<List<Review>>> getReviews(String workerId, {int page = 1});


  Future<Result<Worker>> getMyProfile();

  Future<Result<Worker>> updateProfile(WorkerProfileInput input);

  Future<Result<bool>> setAvailability({required bool available});

  Future<Result<EarningsSummary>> getEarnings();

  Future<Result<List<Job>>> getIncomingJobs();
}

class WorkerProfileInput {
  const WorkerProfileInput({
    this.name,
    this.phone,
    this.bio,
    this.hourlyRate,
    this.skillTypes,
    this.serviceRadiusKm,
    this.pastExperience,
    this.age,
    this.gender,
    this.location,
    this.selectedServiceIds,
    this.profilePic,
    this.cnicFront,
    this.cnicBack,
  });

  final String? name;
  final String? phone;
  final String? bio;
  final double? hourlyRate;
  final List<String>? skillTypes;
  final double? serviceRadiusKm;

  final String? pastExperience;

  final int? age;

  final String? gender;

  final String? location;

  final List<String>? selectedServiceIds;

  final File? profilePic;

  final File? cnicFront;

  final File? cnicBack;
}

class EarningsSummary {
  const EarningsSummary({
    required this.totalGross,
    required this.totalFee,
    required this.totalNet,
    required this.thisMonthGross,
    required this.thisMonthFee,
    required this.thisMonthNet,
    required this.completedJobs,
  });

  /// Agreed job amounts (before platform fee) across all completed work.
  final double totalGross;
  final double totalFee;
  final double totalNet;
  final double thisMonthGross;
  final double thisMonthFee;
  final double thisMonthNet;
  final List<EarningsJob> completedJobs;
}

/// Builds [EarningsSummary] from legacy [Job] rows and labour [ServiceRequest] rows
/// (worker role). Uses [AppConstants.platformFeePercent] for fee/net.
EarningsSummary buildEarningsSummaryFromWork({
  required List<Job> completedJobs,
  required List<ServiceRequest> completedServiceRequests,
}) {
  final rows = <EarningsJob>[];

  for (final j in completedJobs) {
    if (j.status != JobStatus.completed) continue;
    final gross = (j.finalPrice ?? 0.0).clamp(0.0, double.infinity);
    final fee = gross * AppConstants.platformFeePercent;
    final completedAt = j.paidAt ?? j.scheduledDate;
    rows.add(
      EarningsJob(
        jobId: j.jobId,
        serviceType: j.serviceType,
        gross: gross,
        fee: fee,
        net: gross - fee,
        completedAt: completedAt,
        paid: j.paid,
      ),
    );
  }

  for (final r in completedServiceRequests) {
    if (r.status != ServiceRequestStatus.completed) continue;
    final gross = _grossForServiceRequest(r).clamp(0.0, double.infinity);
    final fee = gross * AppConstants.platformFeePercent;
    final completedAt = _completionTimeForServiceRequest(r) ?? DateTime.now();
    rows.add(
      EarningsJob(
        jobId: r.id,
        serviceType: _serviceTypeLabelForRequest(r),
        gross: gross,
        fee: fee,
        net: gross - fee,
        completedAt: completedAt,
        paid: true,
      ),
    );
  }

  rows.sort((a, b) => b.completedAt.compareTo(a.completedAt));

  double sumGross(Iterable<EarningsJob> it) =>
      it.fold<double>(0, (s, e) => s + e.gross);
  double sumFee(Iterable<EarningsJob> it) =>
      it.fold<double>(0, (s, e) => s + e.fee);

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final inMonth = rows
      .where((e) => !e.completedAt.isBefore(monthStart))
      .toList();
  final tg = sumGross(rows);
  final tFee = sumFee(rows);
  final mG = sumGross(inMonth);
  final mFee = sumFee(inMonth);

  return EarningsSummary(
    totalGross: tg,
    totalFee: tFee,
    totalNet: tg - tFee,
    thisMonthGross: mG,
    thisMonthFee: mFee,
    thisMonthNet: mG - mFee,
    completedJobs: rows,
  );
}

String _serviceTypeLabelForRequest(ServiceRequest r) {
  final fromWorker = r.assignedWorker?.services;
  if (fromWorker != null && fromWorker.isNotEmpty) {
    return fromWorker.first.name;
  }
  final d = r.description.trim();
  if (d.isNotEmpty) {
    return d.length > 32 ? d.substring(0, 32) : d;
  }
  return 'Service';
}

double _grossForServiceRequest(ServiceRequest r) {
  final a = r.acceptedBid;
  if (a != null) {
    return a.amount.toDouble();
  }
  final best = r.latestOffer;
  if (best != null) {
    return best.amount.toDouble();
  }
  return 0;
}

DateTime? _completionTimeForServiceRequest(ServiceRequest r) {
  for (final e in r.timeline) {
    if (e.status == ServiceRequestStatus.completed) {
      return e.reachedAt ?? r.updatedAt;
    }
  }
  return r.updatedAt ?? r.createdAt;
}

class EarningsJob {
  const EarningsJob({
    required this.jobId,
    required this.serviceType,
    required this.gross,
    required this.fee,
    required this.net,
    required this.completedAt,
    required this.paid,
  });

  final String jobId;
  final String serviceType;
  final double gross;
  final double fee;
  final double net;
  final DateTime completedAt;
  final bool paid;
}
