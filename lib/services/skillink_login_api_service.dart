import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:skilllink/core/network/api_exception.dart'
    show ApiException, parseApiErrorMessage;
import 'package:skilllink/models/login_models.dart';
import 'package:skilllink/services/google_oauth_request_body.dart';
import 'package:skilllink/services/skillink_api_service.dart';

class SkillinkLoginApiService {
  SkillinkLoginApiService();

  static Map<String, dynamic> _coerceResponseMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  static ApiException _fromDio(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String message =
        parseApiErrorMessage(data) ?? 'Something went wrong';
    return ApiException(
      message: message,
      statusCode: statusCode,
      error: e.response?.data is Map
          ? (e.response?.data as Map)['error'] as String?
          : null,
    );
  }

  static void _debugLogWorkerLoginResponse(String label, Response<dynamic> res) {
    if (!kDebugMode) return;
    final data = res.data;
    if (data is Map) {
      final copy = Map<String, dynamic>.from(data);
      for (final k in const [
        'accessToken',
        'access_token',
        'refreshToken',
        'refresh_token',
        'token',
      ]) {
        if (copy[k] != null) copy[k] = '<redacted>';
      }
      final user = copy['user'];
      if (user is Map) {
        copy['user'] = Map<String, dynamic>.from(user);
      }
      developer.log(
        '$label status=${res.statusCode} body=$copy',
        name: 'SkillinkLogin',
      );
    } else {
      developer.log(
        '$label status=${res.statusCode} body=$data',
        name: 'SkillinkLogin',
      );
    }
  }

  Future<LoginSuccessResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await SkillinkApiService.instance.post(
        '/users/login',
        data: LoginRequest(email: email, password: password).toJson(),
      );
      _debugLogWorkerLoginResponse('POST /users/login', res);
      return LoginSuccessResponse.fromJson(_coerceResponseMap(res.data));
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<LoginSuccessResponse> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      final res = await SkillinkApiService.instance.post(
        '/users/auth/google',
        data: googleOAuthExchangeBody(idToken),
      );
      _debugLogWorkerLoginResponse('POST /users/auth/google', res);
      return LoginSuccessResponse.fromJson(_coerceResponseMap(res.data));
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }
}
