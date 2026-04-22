import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilllink/core/auth/auth_change_notifier.dart';
import 'package:skilllink/models/login_models.dart';
import 'package:skilllink/models/signup_models.dart';
import 'package:skilllink/models/user.dart';
import 'package:skilllink/services/api_service.dart';
import 'package:skilllink/services/skillink_api_service.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/repositories/skillchain_auth_repository.dart'
    show kLabourRolePrefKey;

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _authBackendKey = 'auth_backend';

  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
    String? bio,
    int? age,
    String? gender,
    String? location,
    String? phoneNumber,
    String? education,
    List<String>? offeringSkills,
    List<String>? learningSkills,
    String? pastExperience,
    String? portfolioLink,
  }) async {
    try {
      print('Attempting signup to: ${ApiService.baseUrl}/users/signup');

      final requestData = <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'password': password,
        if (bio != null && bio.isNotEmpty) 'bio': bio,
        if (age != null) 'age': age,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (location != null && location.isNotEmpty) 'location': location,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber,
        if (education != null && education.isNotEmpty) 'education': education,
        if (pastExperience != null && pastExperience.isNotEmpty)
          'pastExperience': pastExperience,
        if (portfolioLink != null && portfolioLink.isNotEmpty)
          'portfolioLink': portfolioLink,
        'profilePic': "",
        'resume': "",
      };

      if (offeringSkills != null && offeringSkills.isNotEmpty) {
        requestData['offeringSkills'] = List<String>.from(offeringSkills);
      } else {
        requestData['offeringSkills'] = <String>[];
      }

      if (learningSkills != null && learningSkills.isNotEmpty) {
        requestData['learningSkills'] = List<String>.from(learningSkills);
      } else {
        requestData['learningSkills'] = <String>[];
      }

      print(
        'Request data with offeringSkills: ${requestData['offeringSkills']}',
      );
      print(
        'Request data with learningSkills: ${requestData['learningSkills']}',
      );

      final response = await _apiService.post(
        '/users/signup',
        data: requestData,
      );

      if (response.statusCode == 201) {
        return {'success': true, 'user': response.data['user']};
      } else {
        return {'success': false, 'message': 'Signup failed'};
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return {
          'success': false,
          'message':
              'Connection timeout. Please check your internet connection.',
        };
      } else if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message':
              'Cannot connect to server. Please check your internet connection and try again.',
        };
      } else if (e.response?.statusCode == 409) {
        return {
          'success': false,
          'message': 'Email or phone number already exists',
        };
      } else if (e.response?.statusCode == 400) {
        final errorData =
            e.response?.data?['message'] ?? e.response?.data?['error'];
        String errorMessage = 'Invalid input data';
        if (errorData != null) {
          if (errorData is List) {
            errorMessage = errorData.join(', ');
          } else if (errorData is String) {
            errorMessage = errorData;
          } else {
            errorMessage = errorData.toString();
          }
        }
        return {'success': false, 'message': errorMessage};
      } else if (e.response != null) {
        final errorData =
            e.response?.data?['message'] ?? e.response?.data?['error'];
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (errorData != null) {
          if (errorData is List) {
            errorMessage = errorData.join(', ');
          } else if (errorData is String) {
            errorMessage = errorData;
          } else {
            errorMessage = errorData.toString();
          }
        }
        return {'success': false, 'message': errorMessage};
      } else {
        return {
          'success': false,
          'message':
              e.message ?? 'Network error. Please check your connection.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/users/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final accessToken = response.data['accessToken'];
        final refreshToken = response.data['refreshToken'];

        await _storage.write(key: _accessTokenKey, value: accessToken);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);

        await _storage.write(key: _userDataKey, value: userData.toString());

        _apiService.setAuthToken(accessToken);

        return {
          'success': true,
          'user': userData,
          'accessToken': accessToken,
          'refreshToken': refreshToken,
        };
      } else {
        return {'success': false, 'message': 'Login failed'};
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return {
          'success': false,
          'message':
              'Connection timeout. Please check your internet connection.',
        };
      } else if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message':
              'Cannot connect to server. Please check your internet connection and try again.',
        };
      } else if (e.response?.statusCode == 401) {
        return {'success': false, 'message': 'Invalid email or password'};
      } else if (e.response?.statusCode == 400) {
        final errorData =
            e.response?.data?['message'] ?? e.response?.data?['error'];
        String errorMessage = 'Invalid input data';
        if (errorData != null) {
          if (errorData is List) {
            errorMessage = errorData.join(', ');
          } else if (errorData is String) {
            errorMessage = errorData;
          } else {
            errorMessage = errorData.toString();
          }
        }
        return {'success': false, 'message': errorMessage};
      } else if (e.response != null) {
        final errorData =
            e.response?.data?['message'] ?? e.response?.data?['error'];
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (errorData != null) {
          if (errorData is List) {
            errorMessage = errorData.join(', ');
          } else if (errorData is String) {
            errorMessage = errorData;
          } else {
            errorMessage = errorData.toString();
          }
        }
        return {'success': false, 'message': errorMessage};
      } else {
        return {
          'success': false,
          'message':
              e.message ?? 'Network error. Please check your connection.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
    await _storage.delete(key: _authBackendKey);
    _apiService.setAuthToken(null);
    SkillinkApiService.instance.setAuthToken(null);
    ApiService.activeAssetBaseUrl = ApiService.baseUrl;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
    bumpAuthChange();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> persistAuthTokens({
    required String accessToken,
    required String refreshToken,
    bool labourBackend = false,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(
      key: _authBackendKey,
      value: labourBackend ? 'labour' : 'digital',
    );
    if (labourBackend) {
      SkillinkApiService.instance.setAuthToken(accessToken);
      _apiService.setAuthToken(null);
      ApiService.activeAssetBaseUrl = AppConstants.apiBaseUrl;
    } else {
      _apiService.setAuthToken(accessToken);
      SkillinkApiService.instance.setAuthToken(null);
      ApiService.activeAssetBaseUrl = ApiService.baseUrl;
    }
    bumpAuthChange();
  }

  Future<bool> isLabourBackend() async {
    final v = await _storage.read(key: _authBackendKey);
    return v == 'labour';
  }

  Future<void> persistAuthFromLogin(
    LoginSuccessResponse response, {
    bool labourBackend = false,
  }) async {
    final userMap = _ensureUserMapHasId(
      Map<String, dynamic>.from(response.user),
      response.accessToken,
    );
    await _storage.write(key: _accessTokenKey, value: response.accessToken);
    await _storage.write(key: _refreshTokenKey, value: response.refreshToken);
    await _storage.write(key: _userDataKey, value: jsonEncode(userMap));
    await _storage.write(
      key: _authBackendKey,
      value: labourBackend ? 'labour' : 'digital',
    );
    if (labourBackend) {
      SkillinkApiService.instance.setAuthToken(response.accessToken);
      _apiService.setAuthToken(null);
      ApiService.activeAssetBaseUrl = AppConstants.apiBaseUrl;
      await _syncLabourRolePrefFrom(userMap);
    } else {
      _apiService.setAuthToken(response.accessToken);
      SkillinkApiService.instance.setAuthToken(null);
      ApiService.activeAssetBaseUrl = ApiService.baseUrl;
    }
    bumpAuthChange();
  }

  Future<void> persistAuthFromSignup(
    SignupSuccessResponse response, {
    bool labourBackend = false,
  }) async {
    final userMap = _ensureUserMapHasId(
      Map<String, dynamic>.from(response.user),
      response.accessToken,
    );
    await _storage.write(key: _accessTokenKey, value: response.accessToken);
    await _storage.write(key: _refreshTokenKey, value: response.refreshToken);
    await _storage.write(key: _userDataKey, value: jsonEncode(userMap));
    await _storage.write(
      key: _authBackendKey,
      value: labourBackend ? 'labour' : 'digital',
    );
    if (labourBackend) {
      SkillinkApiService.instance.setAuthToken(response.accessToken);
      _apiService.setAuthToken(null);
      ApiService.activeAssetBaseUrl = AppConstants.apiBaseUrl;
      await _syncLabourRolePrefFrom(userMap);
    } else {
      _apiService.setAuthToken(response.accessToken);
      SkillinkApiService.instance.setAuthToken(null);
      ApiService.activeAssetBaseUrl = ApiService.baseUrl;
    }
    bumpAuthChange();
  }

  Future<void> _syncLabourRolePrefFrom(Map<String, dynamic> user) async {
    final raw = (user['role'] ?? user['labourApiRole'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    String? role;
    switch (raw) {
      case 'worker':
      case 'provider':
      case 'labour':
      case 'service_provider':
        role = 'worker';
        break;
      case 'user':
      case 'homeowner':
      case 'client':
      case 'customer':
        role = 'homeowner';
        break;
    }
    if (role == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kLabourRolePrefKey, role);
    } catch (_) {}
  }

  Future<void> initializeAuth() async {
    final token = await getAccessToken();
    final labour = await isLabourBackend();
    if (token != null && token.isNotEmpty) {
      if (labour) {
        SkillinkApiService.instance.setAuthToken(token);
        _apiService.setAuthToken(null);
        ApiService.activeAssetBaseUrl = AppConstants.apiBaseUrl;
      } else {
        _apiService.setAuthToken(token);
        SkillinkApiService.instance.setAuthToken(null);
        ApiService.activeAssetBaseUrl = ApiService.baseUrl;
      }
    } else {
      ApiService.activeAssetBaseUrl = ApiService.baseUrl;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final map = await getStoredUserData();
    if (map == null || map.isEmpty) return null;
    return UserModel.fromJson(map);
  }

  Future<UserModel?> refreshCurrentUserFromApi() async {
    if (await isLabourBackend()) {
      return getCurrentUser();
    }
    final stored = await getStoredUserData();
    final id = (stored?['id'] ?? stored?['_id'])?.toString().trim() ?? '';
    if (id.isEmpty) return null;
    try {
      final res = await _apiService.get('/users/user-profile/$id');
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      final userJson = data['user'];
      if (userJson is! Map<String, dynamic>) return null;
      await _storage.write(key: _userDataKey, value: jsonEncode(userJson));
      return UserModel.fromJson(userJson);
    } on DioException {
      return null;
    }
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    await _storage.write(key: _userDataKey, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getStoredUserData() async {
    final raw = await _storage.read(key: _userDataKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return null;
    }
  }

  Future<String> refreshAccessToken() async {
    final refresh = await _storage.read(key: _refreshTokenKey);
    if (refresh == null || refresh.isEmpty) {
      await logout();
      throw Exception('No refresh token');
    }
    try {
      final labour = await isLabourBackend();
      final Response<dynamic> response;
      if (labour) {
        response = await SkillinkApiService.instance.post(
          '/users/refresh',
          data: <String, dynamic>{'refreshToken': refresh},
        );
      } else {
        response = await _apiService.post(
          '/users/refresh',
          data: <String, dynamic>{'refreshToken': refresh},
        );
      }
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final newAccess = data['accessToken'] as String?;
      if (newAccess == null || newAccess.isEmpty) {
        await logout();
        throw Exception('Invalid refresh response');
      }
      await _storage.write(key: _accessTokenKey, value: newAccess);
      if (labour) {
        SkillinkApiService.instance.setAuthToken(newAccess);
      } else {
        _apiService.setAuthToken(newAccess);
      }
      return newAccess;
    } on DioException catch (_) {
      await logout();
      rethrow;
    }
  }

  Map<String, dynamic> _ensureUserMapHasId(
    Map<String, dynamic> user,
    String accessToken,
  ) {
    final existing = _nonEmptyId(user['id']) ?? _nonEmptyId(user['_id']);
    if (existing != null) {
      user['id'] = existing;
      return user;
    }
    final fromJwt = _userIdFromAccessToken(accessToken);
    if (fromJwt != null && fromJwt.isNotEmpty) {
      user['id'] = fromJwt;
    }
    return user;
  }

  String? _nonEmptyId(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  String? _userIdFromAccessToken(String accessToken) {
    if (accessToken.trim().isEmpty) return null;
    final payload = _decodeJwtPayload(accessToken);
    if (payload == null) return null;
    for (final k in const ['sub', 'userId', 'id', 'uid', 'user_id']) {
      final raw = payload[k];
      final s = _nonEmptyId(raw);
      if (s != null) return s;
    }
    return null;
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var seg = parts[1];
      final pad = seg.length % 4;
      if (pad != 0) seg += '=' * (4 - pad);
      final jsonStr = utf8.decode(base64Url.decode(seg));
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }
}
