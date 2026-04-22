import 'dart:io';

import 'package:dio/dio.dart';
import 'package:skilllink/skillink/data/repositories/open_job_post_repository.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/data/services/api_service.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/domain/models/open_job_post_bid.dart';
import 'package:skilllink/skillink/utils/error_mapper.dart';
import 'package:skilllink/skillink/utils/result.dart';

class RemoteOpenJobPostRepository implements OpenJobPostRepository {
  RemoteOpenJobPostRepository({required ApiService apiService})
      : _api = apiService;

  final ApiService _api;

  @override
  Future<Result<OpenJobPost>> createOpenJobPost(
    CreateOpenJobPostInput input,
  ) async {
    try {
      final form = FormData.fromMap(<String, dynamic>{
        if (input.description.trim().isNotEmpty)
          'description': input.description.trim(),
        'scheduledServiceDate': _formatDate(input.scheduledServiceDate),
        'timeSlotStart': input.timeSlotStart,
        'timeSlotEnd': input.timeSlotEnd,
        'serviceAddress': input.serviceAddress,
        'paymentMethod': input.paymentMethod.wire,
      });

      for (final path in input.localPhotoPaths) {
        final file = File(path);
        if (!await file.exists()) continue;
        final contentType = _guessImageMediaType(path);
        form.files.add(
          MapEntry(
            'photos',
            await MultipartFile.fromFile(
              path,
              filename: path.split(Platform.pathSeparator).last,
              contentType: contentType,
            ),
          ),
        );
      }

      final res = await _api.post<Map<String, dynamic>>(
        '/open-job-posts',
        data: form,
      );
      final data = res.data;
      if (data == null) {
        return const Failure('Empty response from server.');
      }
      return Success(OpenJobPost.fromJson(data));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<List<OpenJobPost>>> listMyOpenJobPosts({
    required ServiceRequestRole role,
  }) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/open-job-posts/my',
        queryParameters: {'role': role.wire},
      );
      return _parsePostList(res.data);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<List<OpenJobPost>>> discoverOpenJobPosts() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/open-job-posts/discover',
      );
      return _parsePostList(res.data);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<OpenJobPost>> getOpenJobPost(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/open-job-posts/$id',
      );
      final data = res.data;
      if (data == null) {
        return const Failure('Empty response from server.');
      }
      return Success(OpenJobPost.fromJson(data));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<List<OpenJobPostBid>>> listBidsForOpenJobPost(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/open-job-posts/$id/bids',
      );
      final data = res.data;
      final rawList = data?['bids'] ?? data?['openJobPostBids'] ?? data?['items'];
      if (rawList is! List) return const Success(<OpenJobPostBid>[]);
      final items = rawList
          .whereType<Map<String, dynamic>>()
          .map(OpenJobPostBid.fromJson)
          .toList();
      return Success(items);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<OpenJobPostBid>> submitOpenJobPostBid({
    required String id,
    required num amount,
    required String currency,
    String? note,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        'currency': currency,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      };
      final res = await _api.post<Map<String, dynamic>>(
        '/open-job-posts/$id/bids',
        data: body,
      );
      final data = res.data;
      if (data == null) {
        return const Failure('Empty response from server.');
      }
      return Success(OpenJobPostBid.fromJson(data));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<SelectOpenJobPostBidResult>> selectOpenJobPostBid({
    required String postId,
    required String bidId,
  }) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/open-job-posts/$postId/select-bid',
        data: <String, dynamic>{'bidId': bidId},
      );
      final data = res.data;
      if (data == null) {
        return const Failure('Empty response from server.');
      }
      final postRaw = data['openJobPost'];
      if (postRaw is! Map<String, dynamic>) {
        return const Failure('Unexpected response shape from server.');
      }
      final serviceRequestId = (data['serviceRequestId'] ??
              postRaw['serviceRequestId'] ??
              '')
          .toString();
      if (serviceRequestId.isEmpty) {
        return const Failure(
          'Server accepted the bid but did not return a service request id.',
        );
      }
      return Success(
        SelectOpenJobPostBidResult(
          serviceRequestId: serviceRequestId,
          post: OpenJobPost.fromJson(postRaw),
        ),
      );
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<OpenJobPost>> cancelOpenJobPost(String id) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/open-job-posts/$id/cancel',
      );
      final data = res.data;
      if (data == null) {
        return const Failure('Empty response from server.');
      }
      return Success(OpenJobPost.fromJson(data));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  Result<List<OpenJobPost>> _parsePostList(Map<String, dynamic>? data) {
    final rawList = data?['openJobPosts'] ??
        data?['posts'] ??
        data?['items'] ??
        data?['data'];
    if (rawList is! List) return const Success(<OpenJobPost>[]);
    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map(OpenJobPost.fromJson)
        .toList();
    return Success(items);
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  DioMediaType? _guessImageMediaType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return DioMediaType('image', 'jpeg');
      case 'png':
        return DioMediaType('image', 'png');
      case 'webp':
        return DioMediaType('image', 'webp');
      case 'gif':
        return DioMediaType('image', 'gif');
      case 'heic':
        return DioMediaType('image', 'heic');
      case 'svg':
        return DioMediaType('image', 'svg+xml');
      default:
        return null;
    }
  }
}
