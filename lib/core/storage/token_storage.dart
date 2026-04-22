import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tempSignupTokenKey = 'temp_signup_token';
  static const String _userDataKey = 'user_data';

  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    String? userDataJson,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    if (userDataJson != null) {
      await _storage.write(key: _userDataKey, value: userDataJson);
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveTempSignupToken(String token) async {
    await _storage.write(key: _tempSignupTokenKey, value: token);
  }

  Future<String?> getTempSignupToken() =>
      _storage.read(key: _tempSignupTokenKey);

  Future<void> clearTempSignupToken() async {
    await _storage.delete(key: _tempSignupTokenKey);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tempSignupTokenKey);
    await _storage.delete(key: _userDataKey);
  }
}
