import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/signup_models.dart';
import 'package:skilllink/router/app_router.dart' show skillTypePrefKey;
import 'package:skilllink/services/api_service.dart';
import 'package:skilllink/services/skillink_api_service.dart';
import 'package:skilllink/skillink/data/repositories/skillchain_auth_repository.dart';

class SignupApiService {
  SignupApiService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  static Future<bool> _isLabourSignup() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(skillTypePrefKey) == 'labour';
  }

  static ApiException _fromDio(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String message = 'Something went wrong';
    if (data is Map<String, dynamic>) {
      message = (data['message'] as String?) ?? message;
      if (message.isEmpty || message == 'Something went wrong') {
        final err = data['error'] as String?;
        if (err != null && err.isNotEmpty) message = err;
      }
    }
    return ApiException(
      message: message,
      statusCode: statusCode,
      error: e.response?.data is Map
          ? (e.response?.data['error'] as String?)
          : null,
    );
  }

  Future<VerifyEmailResponse> verifyEmail(String email) async {
    try {
      final res = (await _isLabourSignup())
          ? await SkillinkApiService.instance.post(
              '/users/verify-email',
              data: VerifyEmailRequest(email: email).toJson(),
            )
          : await _api.post(
              '/users/verify-email',
              data: VerifyEmailRequest(email: email).toJson(),
            );
      return VerifyEmailResponse.fromJson(
        res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : {},
      );
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<VerifyOtpSignupResponse> verifyOtpSignup({
    required String email,
    required String otp,
  }) async {
    try {
      final res = (await _isLabourSignup())
          ? await SkillinkApiService.instance.post(
              '/users/verify-otp-signup',
              data: VerifyOtpSignupRequest(email: email, otp: otp).toJson(),
            )
          : await _api.post(
              '/users/verify-otp-signup',
              data: VerifyOtpSignupRequest(email: email, otp: otp).toJson(),
            );
      final map = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      return VerifyOtpSignupResponse.fromJson(map);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<SignupSuccessResponse> signup({
    required String token,
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required int age,
    required String gender,
    required String location,
    required String offeringSkills,
    required String learningSkills,
    String? education,
    String? pastExperience,
    File? profilePic,
    File? portfolio,
    File? resume,
    List<File> certificate = const [],
    File? cnicFront,
    File? cnicBack,
  }) async {
    if (await _isLabourSignup()) {
      if (cnicFront == null ||
          !await cnicFront.exists() ||
          cnicBack == null ||
          !await cnicBack.exists()) {
        throw ApiException(
          message: 'CNIC front and back images are required.',
          statusCode: 400,
        );
      }
      return _signupLabour(
        token: token,
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        age: age,
        gender: gender,
        location: location,
        selectedServices: offeringSkills.trim().isNotEmpty
            ? offeringSkills.trim()
            : (learningSkills.trim().isNotEmpty ? learningSkills.trim() : ''),
        pastExperience: pastExperience ?? '',
        profilePic: profilePic,
        cnicFront: cnicFront,
        cnicBack: cnicBack,
      );
    }

    final formData = FormData.fromMap({
      'token': token,
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'age': age,
      'gender': gender,
      'location': location,
      'offeringSkills': offeringSkills,
      'learningSkills': learningSkills,
      if (education != null && education.isNotEmpty) 'education': education,
      if (pastExperience != null && pastExperience.isNotEmpty)
        'pastExperience': pastExperience,
    });
    if (profilePic != null && await profilePic.exists()) {
      formData.files.add(MapEntry(
        'profilePic',
        await MultipartFile.fromFile(profilePic.path),
      ));
    }
    if (portfolio != null && await portfolio.exists()) {
      formData.files.add(MapEntry(
        'portfolio',
        await MultipartFile.fromFile(portfolio.path),
      ));
    }
    if (resume != null && await resume.exists()) {
      formData.files.add(MapEntry(
        'resume',
        await MultipartFile.fromFile(resume.path),
      ));
    }
    for (final f in certificate) {
      if (await f.exists()) {
        formData.files.add(MapEntry(
          'certificate',
          await MultipartFile.fromFile(f.path),
        ));
      }
    }

    try {
      final res = await _api.postMultipart('/users/signup', data: formData);
      final map = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      return SignupSuccessResponse.fromJson(map);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<SignupSuccessResponse> _signupLabour({
    required String token,
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required int age,
    required String gender,
    required String location,
    required String selectedServices,
    required String pastExperience,
    File? profilePic,
    required File cnicFront,
    required File cnicBack,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final labourRole = prefs.getString(kLabourRolePrefKey);
    final apiRole = labourRole == 'worker' ? 'worker' : 'user';

    final formData = FormData.fromMap({
      'token': token,
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'age': age.toString(),
      'gender': gender,
      'location': location,
      'role': apiRole,
      'selectedServices': selectedServices,
      'pastExperience': pastExperience,
    });
    if (profilePic != null && await profilePic.exists()) {
      formData.files.add(MapEntry(
        'profilePic',
        await MultipartFile.fromFile(profilePic.path),
      ));
    }
    formData.files.addAll([
      MapEntry(
        'cnicFront',
        await MultipartFile.fromFile(cnicFront.path),
      ),
      MapEntry(
        'cnicBack',
        await MultipartFile.fromFile(cnicBack.path),
      ),
    ]);

    try {
      final res = await SkillinkApiService.instance.postMultipart(
        '/users/signup',
        data: formData,
      );
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw ApiException(
          message: 'Signup failed',
          statusCode: res.statusCode,
        );
      }
      final map = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      return SignupSuccessResponse.fromJson(map);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<List<SkillItem>> getSkills() async {
    if (await _isLabourSignup()) return [];
    try {
      final res = await _api.get('/skills/active-skills');
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      final list = data['skills'];
      if (list is! List) return [];
      return List<dynamic>.from(list)
          .map((e) => SkillItem.fromJson(
              e is Map<String, dynamic> ? e : <String, dynamic>{}))
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  Future<List<SkillItem>> fetchActiveLabourServices(String bearerToken) async {
    if (bearerToken.isEmpty) return [];
    final all = <SkillItem>[];
    const limit = 50;
    var offset = 0;
    try {
      while (true) {
        final res = await SkillinkApiService.instance.get(
          '/services/active-services',
          queryParameters: {'limit': limit, 'offset': offset},
          bearerOverride: bearerToken,
        );
        final data = res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : <String, dynamic>{};
        final list = data['services'];
        if (list is List) {
          for (final e in list) {
            if (e is Map<String, dynamic>) {
              all.add(SkillItem.fromJson(e));
            }
          }
        }
        final hasMore = data['hasMore'] == true;
        if (!hasMore) break;
        offset += limit;
        if (offset > 10000) break;
      }
      return all;
    } on DioException catch (_) {
      return [];
    }
  }
}
