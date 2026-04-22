String? parseApiErrorMessage(dynamic data) {
  if (data is! Map) return null;
  final m = data['message'];
  if (m is String && m.trim().isNotEmpty) return m.trim();
  if (m is List) {
    final parts = m.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join('; ');
  }
  final err = data['error'];
  if (err is String && err.trim().isNotEmpty) return err.trim();
  if (err is Map && err['message'] != null) {
    return err['message'].toString();
  }
  return null;
}

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.error,
  });

  final String message;
  final int? statusCode;
  final String? error;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
