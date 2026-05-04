import 'dart:convert';

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
        if (serverMsg != null && serverMsg.isNotEmpty) return serverMsg;
        if (status == 401) return 'Session expired. Please sign in again.';
        if (status == 403) return 'You do not have permission for this action.';
        if (status == 404) return 'Not found.';
        if (status != null && status >= 500) {
          return 'Server error. Please try again shortly.';
        }
        if (status == 400 || status == 422) {
          return 'Invalid request. Please check the form and try again.';
        }
        return 'Request failed.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return 'Network error. Please try again.';
    }
  }

  /// Parses typical REST / NestJS / Express validation bodies so users see
  /// real reasons instead of a generic "Bad request".
  static String? _extractServerMessage(Object? data) {
    final normalized = _normalizePayload(data);
    if (normalized == null) return null;
    if (normalized is String) {
      final s = normalized.trim();
      return s.isEmpty ? null : s;
    }
    if (normalized is! Map) return normalized.toString();

    final map = _stringKeyedMap(normalized);
    if (map == null) return null;

    final fromMessage = _stringifyMessageField(map['message']);
    if (fromMessage != null && fromMessage.isNotEmpty) return fromMessage;

    final fromErrors = _stringifyErrorsField(map['errors']);
    if (fromErrors != null && fromErrors.isNotEmpty) return fromErrors;

    final fromDetails = _stringifyMessageField(map['details']) ??
        _stringifyMessageField(map['detail']);
    if (fromDetails != null && fromDetails.isNotEmpty) return fromDetails;

    if (map['error'] is String) {
      final err = (map['error'] as String).trim();
      if (err.isEmpty) return null;
      if (_isGenericHttpStatusLabel(err)) return null;
      return err;
    }

    final fromDescription = map['description'];
    if (fromDescription is String && fromDescription.trim().isNotEmpty) {
      return fromDescription.trim();
    }

    return null;
  }

  static Object? _normalizePayload(Object? data) {
    if (data == null) return null;
    if (data is Map) return data;
    if (data is String) {
      final s = data.trim();
      if (s.isEmpty) return null;
      try {
        final decoded = jsonDecode(s);
        return decoded ?? s;
      } catch (_) {
        return s;
      }
    }
    return data;
  }

  static Map<String, dynamic>? _stringKeyedMap(Map<dynamic, dynamic> map) {
    try {
      return map.map((k, v) => MapEntry(k.toString(), v));
    } catch (_) {
      return null;
    }
  }

  static String? _stringifyMessageField(Object? value) {
    if (value == null) return null;
    if (value is String) {
      final s = value.trim();
      return s.isEmpty ? null : s;
    }
    if (value is num || value is bool) return value.toString();
    if (value is List) {
      final parts = <String>[];
      for (final item in value) {
        final line = _stringifyMessageField(item);
        if (line != null && line.isNotEmpty) parts.add(line);
      }
      return parts.isEmpty ? null : parts.join('; ');
    }
    if (value is Map) {
      final nested = value['message'] ?? value['msg'] ?? value['description'];
      final inner = _stringifyMessageField(nested);
      if (inner != null) return inner;
      try {
        return jsonEncode(value);
      } catch (_) {
        return value.toString();
      }
    }
    return value.toString();
  }

  static String? _stringifyErrorsField(Object? errors) {
    if (errors == null) return null;
    if (errors is String) {
      final s = errors.trim();
      return s.isEmpty ? null : s;
    }
    if (errors is List) return _stringifyMessageField(errors);
    if (errors is Map) {
      final entries = errors.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      final parts = <String>[];
      for (final e in entries) {
        final key = e.key.toString();
        final formatted = _stringifyMessageField(e.value);
        if (formatted != null && formatted.isNotEmpty) {
          parts.add('$key: $formatted');
        }
      }
      return parts.isEmpty ? null : parts.join('; ');
    }
    return errors.toString();
  }

  static bool _isGenericHttpStatusLabel(String s) {
    switch (s.trim().toLowerCase()) {
      case 'bad request':
      case 'unauthorized':
      case 'forbidden':
      case 'not found':
      case 'internal server error':
      case 'bad gateway':
      case 'service unavailable':
        return true;
      default:
        return false;
    }
  }
}

class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
  @override
  String toString() => 'Google sign-in cancelled';
}
