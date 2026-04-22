import 'package:dio/dio.dart';

import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/login_models.dart';
import 'package:skilllink/services/api_service.dart';
import 'package:skilllink/services/google_oauth_request_body.dart';

class LoginApiService {
  LoginApiService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

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

  Future<LoginSuccessResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.post(
        '/users/login',
        data: LoginRequest(email: email, password: password).toJson(),
      );
      return LoginSuccessResponse.fromJson(_coerceResponseMap(res.data));
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<LoginSuccessResponse> loginWithGoogle({required String idToken}) async {
    try {
      final res = await _api.post(
        '/users/auth/google',
        data: googleOAuthExchangeBody(idToken),
      );
      return LoginSuccessResponse.fromJson(_coerceResponseMap(res.data));
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }
}
