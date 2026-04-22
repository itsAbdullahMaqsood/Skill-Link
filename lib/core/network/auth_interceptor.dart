import 'package:dio/dio.dart';

class AuthInterceptorCallbacks {
  AuthInterceptorCallbacks({
    required this.getAccessToken,
    required this.refreshToken,
    required this.onLogoutRequired,
    required this.attachAccessToken,
  });

  final Future<String?> Function() getAccessToken;
  final Future<String> Function() refreshToken;
  final void Function() onLogoutRequired;

  final Future<bool> Function() attachAccessToken;
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio, AuthInterceptorCallbacks? callbacks}) {
    if (callbacks != null) _callbacks = callbacks;
  }

  final Dio dio;

  static AuthInterceptorCallbacks? _callbacks;

  static void configure(AuthInterceptorCallbacks callbacks) {
    _callbacks = callbacks;
  }

  Future<String>? _refreshFuture;

  static const _retryKey = '_auth_retried';
  static const _refreshPath = '/users/refresh';
  static const _loginPath = '/users/login';
  static const _signupPath = '/users/signup';
  static const _verifyEmailPath = '/users/verify-email';
  static const _verifyOtpPathSignup = '/users/verify-otp-signup';
  static const _forgotPasswordPath = '/users/forgot-password';
  static const _verifyOtpPath = '/users/verify-otp';
  static const _resetPasswordPath = '/users/reset-password';
  static const _googleAuthPath = '/users/auth/google';

  bool _isAuthEndpoint(RequestOptions options) {
    final path = options.path;
    return path.contains(_refreshPath) ||
        path.contains(_loginPath) ||
        path.contains(_signupPath) ||
        path.contains(_verifyEmailPath) ||
        path.contains(_verifyOtpPathSignup) ||
        path.contains(_forgotPasswordPath) ||
        path.contains(_verifyOtpPath) ||
        path.contains(_resetPasswordPath) ||
        path.contains(_googleAuthPath);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_callbacks == null) {
      handler.next(options);
      return;
    }
    if (_isAuthEndpoint(options)) {
      handler.next(options);
      return;
    }
    try {
      if (!await _callbacks!.attachAccessToken()) {
        handler.next(options);
        return;
      }
      final token = await _callbacks!.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final options = err.requestOptions;

    if (response?.statusCode != 401 ||
        _callbacks == null ||
        _isAuthEndpoint(options)) {
      handler.next(err);
      return;
    }

    if (options.extra[_retryKey] == true) {
      handler.next(err);
      return;
    }

    try {
      if (!await _callbacks!.attachAccessToken()) {
        handler.next(err);
        return;
      }
      _refreshFuture ??= _callbacks!.refreshToken();
      await _refreshFuture!;
    } catch (_) {
      _refreshFuture = null;
      _callbacks!.onLogoutRequired();
      handler.next(err);
      return;
    } finally {
      _refreshFuture = null;
    }

    options.extra[_retryKey] = true;
    try {
      final token = await _callbacks!.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      final res = await dio.fetch(options);
      handler.resolve(res);
    } catch (e) {
      if (e is DioException) {
        handler.next(e);
      } else {
        handler.next(err);
      }
    }
  }
}
