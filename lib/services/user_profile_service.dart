import 'dart:io';

import 'package:dio/dio.dart';

import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/user.dart';
import 'package:skilllink/services/api_service.dart';
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/services/skillink_api_service.dart';

class UserProfileService {
  UserProfileService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;
  final AuthService _auth = AuthService();

  static ApiException _fromDio(DioException e) {
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
      statusCode: e.response?.statusCode,
      error: data is Map ? (data['error'] as String?) : null,
    );
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String bio,
    required int age,
    required String gender,
    required String location,
    required String phoneNumber,
    required String education,
    required List<String> offeringSkills,
    required List<String> learningSkills,
    required String pastExperience,
    File? profilePic,
    File? resume,
    File? portfolio,
    List<File> certificates = const [],
    String? cnicFrontPath,
    String? cnicBackPath,
    File? cnicFrontFile,
    File? cnicBackFile,
  }) async {
    if (await _auth.isLabourBackend()) {
      return _updateProfileLabour(
        fullName: fullName,
        bio: bio,
        age: age,
        gender: gender,
        location: location,
        phoneNumber: phoneNumber,
        pastExperience: pastExperience,
        selectedServices: offeringSkills.isNotEmpty
            ? offeringSkills.join(',')
            : learningSkills.join(','),
        profilePic: profilePic,
        cnicFrontPath: cnicFrontPath,
        cnicBackPath: cnicBackPath,
        cnicFrontFile: cnicFrontFile,
        cnicBackFile: cnicBackFile,
      );
    }

    final formData = FormData.fromMap({
      'fullName': fullName,
      'bio': bio,
      'age': age,
      'gender': gender,
      'location': location,
      'phoneNumber': phoneNumber,
      'education': education,
      'pastExperience': pastExperience,
    });
    for (final id in offeringSkills) {
      formData.fields.add(MapEntry('offeringSkills', id));
    }
    for (final id in learningSkills) {
      formData.fields.add(MapEntry('learningSkills', id));
    }

    if (profilePic != null && await profilePic.exists()) {
      formData.files.add(MapEntry(
        'profilePic',
        await MultipartFile.fromFile(profilePic.path),
      ));
    }
    if (resume != null && await resume.exists()) {
      formData.files.add(MapEntry(
        'resume',
        await MultipartFile.fromFile(resume.path),
      ));
    }
    if (portfolio != null && await portfolio.exists()) {
      formData.files.add(MapEntry(
        'portfolio',
        await MultipartFile.fromFile(portfolio.path),
      ));
    }
    for (final f in certificates) {
      if (await f.exists()) {
        formData.files.add(MapEntry(
          'certificate',
          await MultipartFile.fromFile(f.path),
        ));
      }
    }

    try {
      final res = await _api.putMultipart('/users/profile', data: formData);
      final map = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      final userJson = map['user'];
      if (userJson is! Map<String, dynamic>) {
        throw ApiException(message: 'Invalid response: missing user');
      }
      return userJson;
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<Map<String, dynamic>> _updateProfileLabour({
    required String fullName,
    required String bio,
    required int age,
    required String gender,
    required String location,
    required String phoneNumber,
    required String pastExperience,
    required String selectedServices,
    File? profilePic,
    String? cnicFrontPath,
    String? cnicBackPath,
    File? cnicFrontFile,
    File? cnicBackFile,
  }) async {
    final stored = await _auth.getStoredUserData();
    final role = (stored?['role'] ?? 'user').toString();
    final formData = FormData.fromMap({
      'fullName': fullName,
      'bio': bio,
      'age': age.toString(),
      'gender': gender,
      'location': location,
      'phoneNumber': phoneNumber,
      'role': role.isEmpty ? 'user' : role,
      'selectedServices': selectedServices,
      'pastExperience': pastExperience,
    });

    if (profilePic != null && await profilePic.exists()) {
      formData.files.add(MapEntry(
        'profilePic',
        await MultipartFile.fromFile(profilePic.path),
      ));
    }
    if (cnicFrontFile != null && await cnicFrontFile.exists()) {
      formData.files.add(MapEntry(
        'cnicFront',
        await MultipartFile.fromFile(cnicFrontFile.path),
      ));
    } else if (cnicFrontPath != null && cnicFrontPath.isNotEmpty) {
      formData.fields.add(MapEntry('cnicFront', cnicFrontPath));
    }
    if (cnicBackFile != null && await cnicBackFile.exists()) {
      formData.files.add(MapEntry(
        'cnicBack',
        await MultipartFile.fromFile(cnicBackFile.path),
      ));
    } else if (cnicBackPath != null && cnicBackPath.isNotEmpty) {
      formData.fields.add(MapEntry('cnicBack', cnicBackPath));
    }

    try {
      final res = await SkillinkApiService.instance.postMultipart(
        '/users/profile',
        data: formData,
      );
      final raw = res.data;
      if (raw is Map<String, dynamic>) {
        final userJson = raw['user'];
        if (userJson is Map<String, dynamic>) return userJson;
        if (raw.containsKey('email') || raw.containsKey('id')) {
          return Map<String, dynamic>.from(raw);
        }
      }
      throw ApiException(message: 'Invalid response: missing user');
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<UserModel> fetchPublicProfile(String userId) async {
    try {
      final res = await _api.get('/users/user-profile/$userId');
      final map = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      final userJson = map['user'];
      if (userJson is! Map<String, dynamic>) {
        throw ApiException(message: 'Invalid response: missing user');
      }
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }
}
