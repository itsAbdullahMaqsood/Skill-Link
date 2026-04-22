import 'dart:io';

import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/utils/result.dart';

class WorkerSearchFilter {
  const WorkerSearchFilter({
    this.trade,
    this.lat,
    this.lng,
    this.radiusKm,
    this.minRating,
    this.sort = WorkerSort.ratingDesc,
  });

  final String? trade;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final double? minRating;
  final WorkerSort sort;

  WorkerSearchFilter copyWith({
    Object? trade = _sentinel,
    Object? lat = _sentinel,
    Object? lng = _sentinel,
    Object? radiusKm = _sentinel,
    Object? minRating = _sentinel,
    WorkerSort? sort,
  }) {
    return WorkerSearchFilter(
      trade: trade == _sentinel ? this.trade : trade as String?,
      lat: lat == _sentinel ? this.lat : lat as double?,
      lng: lng == _sentinel ? this.lng : lng as double?,
      radiusKm: radiusKm == _sentinel ? this.radiusKm : radiusKm as double?,
      minRating:
          minRating == _sentinel ? this.minRating : minRating as double?,
      sort: sort ?? this.sort,
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
    required this.thisMonthGross,
    required this.thisMonthFee,
    required this.thisMonthNet,
    required this.completedJobs,
  });

  final double thisMonthGross;
  final double thisMonthFee;
  final double thisMonthNet;
  final List<EarningsJob> completedJobs;
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
