import 'dart:io';

import 'package:dio/dio.dart';
import 'package:skilllink/models/user.dart' as sc;
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/services/signup_api_service.dart';
import 'package:skilllink/skillink/data/mappers/review_from_labour_api.dart';
import 'package:skilllink/skillink/data/mappers/worker_from_labour_api.dart';
import 'package:skilllink/skillink/data/mappers/worker_from_skillchain_user.dart';
import 'package:skilllink/skillink/data/model/worker_dto.dart';
import 'package:skilllink/skillink/data/repositories/job_repository.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart'
    show ServiceRequestRepository, ServiceRequestRole;
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';
import 'package:skilllink/skillink/data/services/api_service.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/testing/models/sample_reviews.dart';
import 'package:skilllink/skillink/utils/error_mapper.dart';
import 'package:skilllink/skillink/utils/result.dart';

List<dynamic> _workersListFromBody(Map<String, dynamic>? body) {
  if (body == null) return const <dynamic>[];
  final direct = body['workers'];
  if (direct is List<dynamic>) return direct;
  if (direct is List) return List<dynamic>.from(direct);
  final data = body['data'];
  if (data is List<dynamic>) return data;
  if (data is List) return List<dynamic>.from(data);
  if (data is Map) {
    final m = Map<String, dynamic>.from(data);
    for (final key in ['workers', 'items', 'results', 'list']) {
      final inner = m[key];
      if (inner is List<dynamic>) return inner;
      if (inner is List) return List<dynamic>.from(inner);
    }
  }
  return const <dynamic>[];
}

class RemoteWorkerRepository implements WorkerRepository {
  RemoteWorkerRepository({
    required ApiService apiService,
    AuthService? authService,
    required JobRepository jobRepository,
    required ServiceRequestRepository serviceRequestRepository,
  })  : _api = apiService,
        _auth = authService,
        _jobs = jobRepository,
        _serviceRequests = serviceRequestRepository;

  final ApiService _api;
  final AuthService? _auth;
  final JobRepository _jobs;
  final ServiceRequestRepository _serviceRequests;

  @override
  Future<Result<List<Worker>>> searchWorkers(
    WorkerSearchFilter filter,
  ) async {
    try {
      const limit = 50;
      // Do not send UI trade slugs as `search` — many backends treat `search`
      // as name/text filter and return [] when it does not match worker names.
      // Trade filtering is applied client-side using service IDs + catalog.
      final res = await _api.get<Map<String, dynamic>>(
        '/workers',
        queryParameters: <String, dynamic>{
          'limit': limit,
          'offset': 0,
          if (filter.minRating != null) 'minRating': filter.minRating,
        },
      );
      final body = res.data;
      final rawList = _workersListFromBody(body);
      var workers = rawList
          .cast<Map<String, dynamic>>()
          .map(workerFromLabourApiJson)
          .toList();

      Map<String, String>? idToName = filter.serviceIdToName;
      if ((idToName == null || idToName.isEmpty) &&
          filter.trade != null &&
          filter.trade!.trim().isNotEmpty) {
        final auth = _auth;
        if (auth != null) {
          try {
            final token = await auth.getAccessToken();
            if (token != null && token.isNotEmpty) {
              final items =
                  await SignupApiService().fetchActiveLabourServices(token);
              idToName = {for (final s in items) s.id: s.name};
            }
          } catch (_) {}
        }
      }

      final trade = filter.trade?.trim();
      if (trade != null && trade.isNotEmpty) {
        workers = workers
            .where(
              (w) => workerMatchesMarketplaceTrade(
                w,
                trade,
                idToName,
              ),
            )
            .toList();
      }

      if (filter.minRating != null) {
        workers =
            workers.where((w) => w.rating >= filter.minRating!).toList();
      }

      switch (filter.sort) {
        case WorkerSort.ratingDesc:
          workers.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case WorkerSort.distanceAsc:
          workers.sort((a, b) => (a.distanceKm ?? double.infinity)
              .compareTo(b.distanceKm ?? double.infinity));
          break;
        case WorkerSort.priceAsc:
          workers.sort((a, b) => (a.hourlyRate ?? double.infinity)
              .compareTo(b.hourlyRate ?? double.infinity));
          break;
      }

      final radius = filter.radiusKm;
      if (radius != null) {
        workers = workers
            .where((w) =>
                w.distanceKm != null && w.distanceKm! <= radius)
            .toList();
      }

      return Success(workers);
    } on DioException catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<Worker>> getWorker(String id) async {
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
    try {
      final res = await _api.get<Map<String, dynamic>>('/workers/$id');
      final data = res.data;
      if (data == null) return const Failure('Worker not found.');

      Map<String, dynamic> payload = data;
      final nested = data['worker'];
      if (nested is Map<String, dynamic>) {
        payload = nested;
      }

      try {
        final w = workerFromLabourApiJson(payload);
        if (w.id.isNotEmpty) {
          return Success(w);
        }
      } on Object {
      }
      return Success(WorkerDto.fromJson(payload).toDomain());
    } on DioException catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<List<Review>>> getReviews(
    String workerId, {
    int page = 1,
  }) async {
    final auth = _auth;
    if (auth != null && workerId.trim().isNotEmpty) {
      try {
        if (await auth.isLabourBackend()) {
          final u = await auth.getCurrentUser();
          if (u != null && u.id == workerId) {
            return Success(SampleReviews.forWorker(workerId));
          }
        }
      } catch (_) {
      }
    }
    List<Review> parseReviewList(List<dynamic> list) {
      final out = <Review>[];
      for (final e in list) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        try {
          out.add(Review.fromJson(m));
        } catch (_) {
          final loose = reviewFromLabourApiJson(m);
          if (loose != null) out.add(loose);
        }
      }
      return out;
    }

    try {
      final res = await _api.get<dynamic>(
        '/workers/$workerId/reviews',
        queryParameters: {'page': page},
      );
      final data = res.data;
      if (data is List) {
        return Success(parseReviewList(data));
      }
      if (data is Map<String, dynamic>) {
        final inner = data['reviews'] ?? data['data'] ?? data['items'];
        if (inner is List) {
          return Success(parseReviewList(inner));
        }
        return Success(reviewsFromLabourApiResponse(data));
      }
      return const Success([]);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Success([]);
      }
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }


  @override
  Future<Result<Worker>> getMyProfile() async {
    final auth = _auth;
    if (auth != null) {
      try {
        if (await auth.isLabourBackend()) {
          final u = await auth.getCurrentUser();
          if (u != null) {
            if (u.labourApiRole.trim().isNotEmpty && !u.isLabourWorkerRole) {
              return const Failure(
                'This account is registered as a homeowner, not a worker.',
              );
            }
            return Success(WorkerFromSkillChainUser.map(u));
          }
        }
      } catch (_) {
      }
    }
    return const Failure('Remote worker profile not yet implemented.');
  }

  @override
  Future<Result<Worker>> updateProfile(WorkerProfileInput input) async {
    try {
      final form = FormData();
      void addField(String key, String? value) {
        if (value == null) return;
        form.fields.add(MapEntry(key, value));
      }

      addField('fullName', input.name?.trim());
      addField('phoneNumber', input.phone?.trim());
      addField('bio', input.bio?.trim());
      addField('pastExperience', input.pastExperience?.trim());
      addField('gender', input.gender?.trim());
      addField('location', input.location?.trim());
      if (input.age != null) addField('age', input.age!.toString());

      if (input.selectedServiceIds != null) {
        addField(
          'selectedServices',
          input.selectedServiceIds!.where((e) => e.trim().isNotEmpty).join(','),
        );
      }

      Future<void> attach(String key, File? file) async {
        if (file == null) return;
        if (!await file.exists()) return;
        form.files.add(
          MapEntry(key, await MultipartFile.fromFile(file.path)),
        );
      }

      await attach('profilePic', input.profilePic);
      await attach('cnicFront', input.cnicFront);
      await attach('cnicBack', input.cnicBack);

      final res = await _api.postMultipart<Map<String, dynamic>>(
        '/workers/profile',
        data: form,
      );

      final body = res.data ?? const <String, dynamic>{};
      final userJson = body['user'] is Map<String, dynamic>
          ? body['user'] as Map<String, dynamic>
          : body;
      if (userJson.isEmpty) {
        return const Failure('Profile update returned no user payload.');
      }

      final auth = _auth;
      if (auth != null) {
        try {
          await auth.saveUserData(userJson);
        } catch (_) {
        }
      }

      final userModel = sc.UserModel.fromJson(userJson);
      return Success(WorkerFromSkillChainUser.map(userModel));
    } on DioException catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<bool>> setAvailability({required bool available}) async =>
      const Failure('Remote availability toggle not yet implemented.');

  @override
  Future<Result<EarningsSummary>> getEarnings() async {
    String? jobListErr;
    var rawJobs = const <Job>[];
    final jobsResult = await _jobs.listJobs();
    jobsResult.when(
      success: (list) => rawJobs = list,
      failure: (msg, _) => jobListErr = msg,
    );
    String? serviceErr;
    var rawServiceRequests = const <ServiceRequest>[];
    final srResult = await _serviceRequests.listMyRequests(
      role: ServiceRequestRole.worker,
    );
    srResult.when(
      success: (list) => rawServiceRequests = list,
      failure: (msg, _) => serviceErr = msg,
    );

    if (jobListErr != null && serviceErr != null) {
      return Failure('Could not load earnings: $jobListErr');
    }

    final completedJobs = rawJobs
        .where((j) => j.status == JobStatus.completed)
        .toList();
    final completedServiceRequests = rawServiceRequests
        .where((r) => r.status == ServiceRequestStatus.completed)
        .toList();
    return Success(
      buildEarningsSummaryFromWork(
        completedJobs: completedJobs,
        completedServiceRequests: completedServiceRequests,
      ),
    );
  }

  @override
  Future<Result<List<Job>>> getIncomingJobs() async =>
      const Failure('Remote incoming jobs not yet implemented.');
}
