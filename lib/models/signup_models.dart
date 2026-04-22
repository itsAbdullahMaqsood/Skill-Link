
class VerifyEmailRequest {
  VerifyEmailRequest({required this.email});
  final String email;
  Map<String, dynamic> toJson() => {'email': email};
}

class VerifyEmailResponse {
  VerifyEmailResponse({required this.message});
  final String message;
  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) =>
      VerifyEmailResponse(message: json['message'] as String? ?? '');
}

class VerifyOtpSignupRequest {
  VerifyOtpSignupRequest({required this.email, required this.otp});
  final String email;
  final String otp;
  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

class VerifyOtpSignupResponse {
  VerifyOtpSignupResponse({
    required this.message,
    required this.token,
    required this.expiresIn,
  });
  final String message;
  final String token;
  final int expiresIn;
  factory VerifyOtpSignupResponse.fromJson(Map<String, dynamic> json) =>
      VerifyOtpSignupResponse(
        message: json['message'] as String? ?? '',
        token: json['token'] as String? ?? '',
        expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
      );
}

class SignupSuccessResponse {
  SignupSuccessResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
  final Map<String, dynamic> user;
  final String accessToken;
  final String refreshToken;

  factory SignupSuccessResponse.fromJson(Map<String, dynamic> json) {
    final root = _unwrapSignupEnvelope(json);
    final accessToken = _signupPickString(
      root,
      const ['accessToken', 'access_token', 'token'],
    );
    final refreshToken =
        _signupPickString(root, const ['refreshToken', 'refresh_token']);

    Map<String, dynamic> userMap = _signupCoerceUser(root['user']);
    if (userMap.isEmpty) {
      userMap = _signupUserMapFromFlat(root);
    }

    return SignupSuccessResponse(
      user: userMap,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

Map<String, dynamic> _unwrapSignupEnvelope(Map<String, dynamic> json) {
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

String _signupPickString(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return '';
}

Map<String, dynamic> _signupCoerceUser(dynamic user) {
  if (user is! Map) return <String, dynamic>{};
  return Map<String, dynamic>.from(user);
}

Map<String, dynamic> _signupUserMapFromFlat(Map<String, dynamic> root) {
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
  final hasSignal = root.containsKey('email') ||
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
  return copy;
}

class SkillItem {
  SkillItem({required this.id, required this.name});
  final String id;
  final String name;
  factory SkillItem.fromJson(Map<String, dynamic> json) => SkillItem(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        name: (json['name'] ?? json['title'] ?? '').toString(),
      );
}
