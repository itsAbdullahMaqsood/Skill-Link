import 'dart:io';

import 'package:dio/dio.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/data/services/api_service.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/utils/error_mapper.dart';
import 'package:skilllink/skillink/utils/result.dart';

class RemoteServiceRequestRepository implements ServiceRequestRepository {
  RemoteServiceRequestRepository({required ApiService apiService})
      : _api = apiService;

  final ApiService _api;

  @override
  Future<Result<ServiceRequest>> createServiceRequest(
    CreateServiceRequestInput input,
  ) async {
    try {
      final form = FormData.fromMap(<String, dynamic>{
        'requestedWorkerId': input.requestedWorkerId,
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
        '/request-services',
        data: form,
      );
      final data = res.data;
      if (data == null) {
        return const Failure('Empty response from server.');
      }
      return Success(ServiceRequest.fromJson(data));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<ServiceRequest>> getServiceRequest(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/request-services/$id',
      );
      final data = res.data;
      if (data == null) {
        return const Failure('Empty response from server.');
      }
      return Success(ServiceRequest.fromJson(data));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<List<ServiceRequest>>> listMyRequests({
    required ServiceRequestRole role,
  }) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/request-services/my',
        queryParameters: {'role': role.wire},
      );
      final data = res.data;
      final rawList = data?['serviceRequests'] ??
          data?['requests'] ??
          data?['items'];
      if (rawList is! List) return const Success(<ServiceRequest>[]);
      final items = rawList
          .whereType<Map<String, dynamic>>()
          .map(ServiceRequest.fromJson)
          .toList();
      return Success(items);
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  @override
  Future<Result<ServiceRequest>> customerCounterOffer({
    required String id,
    required num amount,
    required String currency,
  }) =>
      _postBid('/request-services/$id/customer/counter-offer',
          amount: amount, currency: currency);

  @override
  Future<Result<ServiceRequest>> customerAcceptBid(String id) =>
      _postAction('/request-services/$id/customer/accept-bid');

  @override
  Future<Result<ServiceRequest>> cancel(String id) =>
      _postAction('/request-services/$id/cancel');


  @override
  Future<Result<ServiceRequest>> workerAccept(String id) =>
      _postAction('/request-services/$id/worker/accept');

  @override
  Future<Result<ServiceRequest>> workerBid({
    required String id,
    required num amount,
    required String currency,
  }) =>
      _postBid('/request-services/$id/worker/bid',
          amount: amount, currency: currency);

  @override
  Future<Result<ServiceRequest>> workerOnTheWay(String id) =>
      _postAction('/request-services/$id/worker/on-the-way');

  @override
  Future<Result<ServiceRequest>> workerArrived(String id) =>
      _postAction('/request-services/$id/worker/arrived');

  @override
  Future<Result<ServiceRequest>> workerStart(String id) =>
      _postAction('/request-services/$id/worker/start');

  @override
  Future<Result<ServiceRequest>> workerComplete(String id) =>
      _postAction('/request-services/$id/worker/complete');

  Future<Result<ServiceRequest>> _postAction(String path) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(path);
      final data = res.data;
      if (data == null) {
        return const Failure('Empty response from server.');
      }
      return Success(ServiceRequest.fromJson(data));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
  }

  Future<Result<ServiceRequest>> _postBid(
    String path, {
    required num amount,
    required String currency,
  }) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        path,
        data: <String, dynamic>{'amount': amount, 'currency': currency},
      );
      final data = res.data;
      if (data == null) {
        return const Failure('Empty response from server.');
      }
      return Success(ServiceRequest.fromJson(data));
    } on Exception catch (e) {
      return Failure(ErrorMapper.fromException(e), e);
    }
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
