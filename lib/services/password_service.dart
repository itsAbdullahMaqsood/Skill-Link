import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skilllink/router/app_router.dart' show skillTypePrefKey;
import 'package:skilllink/services/api_service.dart';
import 'package:skilllink/services/skillink_api_service.dart';

class PasswordService {
  final ApiService _api = ApiService();

  static Future<bool> _isLabourSignup() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(skillTypePrefKey) == 'labour';
  }

  Future<void> forgotPassword(String email) async {
    try {
      if (await _isLabourSignup()) {
        await SkillinkApiService.instance.post(
          '/users/forgot-password',
          data: <String, dynamic>{'email': email.trim()},
        );
      } else {
        await _api.post(
          '/users/forgot-password',
          data: <String, dynamic>{'email': email.trim()},
        );
      }
    } on DioException catch (e) {
      final message = _messageFromResponse(e) ?? 'Something went wrong';
      throw Exception(message);
    }
  }

  Future<String> verifyOtp(String email, String otp) async {
    try {
      final response = (await _isLabourSignup())
          ? await SkillinkApiService.instance.post(
              '/users/verify-otp',
              data: <String, dynamic>{
                'email': email.trim(),
                'otp': otp.trim(),
              },
            )
          : await _api.post(
              '/users/verify-otp',
              data: <String, dynamic>{
                'email': email.trim(),
                'otp': otp.trim(),
              },
            );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final token = data['resetToken'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Invalid response: no reset token');
      }
      return token;
    } on DioException catch (e) {
      final message = _messageFromResponse(e) ?? 'Something went wrong';
      throw Exception(message);
    }
  }

  Future<void> resetPassword(String token, String password) async {
    try {
      if (await _isLabourSignup()) {
        await SkillinkApiService.instance.post(
          '/users/reset-password',
          data: <String, dynamic>{
            'token': token,
            'password': password,
          },
        );
      } else {
        await _api.post(
          '/users/reset-password',
          data: <String, dynamic>{
            'token': token,
            'password': password,
          },
        );
      }
    } on DioException catch (e) {
      final message = _messageFromResponse(e) ?? 'Something went wrong';
      throw Exception(message);
    }
  }

  static String? _messageFromResponse(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      final err = data['error'];
      if (err is String && err.isNotEmpty) return err;
    }
    return null;
  }
}
