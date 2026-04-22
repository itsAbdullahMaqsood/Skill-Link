import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'package:skilllink/skillink/config/app_constants.dart';

class SkillinkApiService {
  SkillinkApiService._();
  static final SkillinkApiService instance = SkillinkApiService._();
  factory SkillinkApiService() => instance;

  Dio? _dio;

  Dio get dio => _dio ??= _createDio();

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    return dio;
  }

  void setAuthToken(String? token) {
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? bearerOverride,
  }) async {
    if (bearerOverride != null && bearerOverride.isNotEmpty) {
      return dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: {'Authorization': 'Bearer $bearerOverride'},
        ),
      );
    }
    return dio.get<dynamic>(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) async {
    return dio.post<dynamic>(path, data: data);
  }

  Future<Response<dynamic>> postMultipart(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }
}
