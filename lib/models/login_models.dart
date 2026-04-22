
class LoginRequest {
  LoginRequest({required this.email, required this.password});
  final String email;
  final String password;
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginSuccessResponse {
  LoginSuccessResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
  final Map<String, dynamic> user;
  final String accessToken;
  final String refreshToken;

  factory LoginSuccessResponse.fromJson(Map<String, dynamic> json) {
    final root = _unwrapAuthEnvelope(json);
    final accessToken = _pickString(root, const [
      'accessToken',
      'access_token',
      'token',
    ]);
    final refreshToken = _pickString(root, const [
      'refreshToken',
      'refresh_token',
    ]);

    Map<String, dynamic> userMap = _coerceUserMap(root['user']);
    if (userMap.isEmpty) {
      userMap = _userMapFromFlatResponse(root);
    }

    return LoginSuccessResponse(
      user: userMap,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

Map<String, dynamic> _unwrapAuthEnvelope(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map) {
    final out = Map<String, dynamic>.from(json);
    out.remove('data');
    Map<String, dynamic>.from(data).forEach((k, v) {
      out[k] = v;
    });
    return out;
  }
  return json;
}

String _pickString(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return '';
}

Map<String, dynamic> _coerceUserMap(dynamic user) {
  if (user is! Map) return <String, dynamic>{};
  return Map<String, dynamic>.from(user);
}

Map<String, dynamic> _userMapFromFlatResponse(Map<String, dynamic> root) {
  const skip = <String>{
    'accessToken',
    'access_token',
    'refreshToken',
    'refresh_token',
    'token',
    'message',
    'success',
    'statusCode',
    'data',
  };
  final hasSignal =
      root.containsKey('email') ||
      root.containsKey('fullName') ||
      root.containsKey('name') ||
      root.containsKey('phone') ||
      root.containsKey('phoneNumber') ||
      root.containsKey('_id') ||
      root.containsKey('id');
  if (!hasSignal) return <String, dynamic>{};

  final copy = Map<String, dynamic>.from(root);
  for (final k in skip) {
    copy.remove(k);
  }
  if (copy.isEmpty) return <String, dynamic>{};
  return copy;
}
