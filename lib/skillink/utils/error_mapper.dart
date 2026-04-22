import 'package:dio/dio.dart';

class ErrorMapper {
  ErrorMapper._();

  static String fromException(Object e) {
    if (e is DioException) return _fromDio(e);
    if (e is GoogleSignInCancelled) return 'Google sign-in cancelled';
    return 'Something went wrong. Please try again.';
  }

  static String _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final serverMsg = _extractServerMessage(e.response?.data);
        if (serverMsg != null) return serverMsg;
        if (status == 401) return 'Session expired. Please sign in again.';
        if (status == 403) return 'You do not have permission for this action.';
        if (status == 404) return 'Not found.';
        if (status != null && status >= 500) {
          return 'Server error. Please try again shortly.';
        }
        return 'Request failed.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return 'Network error. Please try again.';
    }
  }

  static String? _extractServerMessage(Object? data) {
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (data is Map && data['error'] is String) return data['error'] as String;
    return null;
  }
}

class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
  @override
  String toString() => 'Google sign-in cancelled';
}
