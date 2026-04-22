import 'package:dio/dio.dart';
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/skillink/config/app_constants.dart';

class ApiService {
  ApiService({
    required AuthService authService,
    Dio? dio,
  })  : _auth = authService,
        _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = AppConstants.apiBaseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..headers = {'Content-Type': 'application/json'};

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _auth.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['retried'] != true) {
            try {
              final refreshed = await _auth.refreshAccessToken();
              if (refreshed.isNotEmpty) {
                final req = error.requestOptions
                  ..extra['retried'] = true
                  ..headers['Authorization'] = 'Bearer $refreshed';
                try {
                  final response = await _dio.fetch<dynamic>(req);
                  return handler.resolve(response);
                } on DioException catch (e) {
                  return handler.next(e);
                }
              }
            } catch (_) {
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final AuthService _auth;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {Object? data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> patch<T>(String path, {Object? data}) =>
      _dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);

  Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.post<T>(
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
