import 'package:skilllink/services/api_service.dart';

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

String _mongoIdOrString(dynamic raw) {
  if (raw == null) return '';
  if (raw is Map) {
    final oid = raw[r'$oid'] ?? raw['oid'];
    if (oid != null) return oid.toString().trim();
  }
  return raw.toString().trim();
}

String _skillToDisplayName(dynamic e) {
  if (e == null) return '';
  if (e is Map) {
    final name = e['name'] ?? e['Name'];
    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString().trim();
    }
  }
  if (e is String) return e.trim();
  return '';
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final int age;
  final String gender;
  final String location;
  final String phoneNumber;
  final String portfolioLink;
  final bool verified;

  final String? bio;
  final String? profilePic;
  final String? education;
  final List<String> offeringSkills;
  final List<String> learningSkills;
  final String? pastExperience;
  final String? resume;
  final String? portfolio;
  final String? cnicFront;
  final String? cnicBack;
  final int timeCoins;
  final String? subscriptionPackage;
  final double ratings;
  final int reviewsCount;
  final List<Review> reviews;
  final String status;

  final String labourApiRole;
  final bool isPremium;
  final List<String> earnedCertificates;
  final List<String> myOffers;

  final String? username;
  final int? posts;
  final int? donations;
  final int? connections;
  final String? linkedin;
  final String? github;
  final String? twitter;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.age,
    required this.gender,
    required this.location,
    required this.phoneNumber,
    required this.portfolioLink,
    required this.verified,
    this.bio,
    this.profilePic,
    this.education,
    this.offeringSkills = const [],
    this.learningSkills = const [],
    this.pastExperience,
    this.resume,
    this.portfolio,
    this.cnicFront,
    this.cnicBack,
    this.timeCoins = 0,
    this.subscriptionPackage,
    this.ratings = 0.0,
    this.reviewsCount = 0,
    this.reviews = const [],
    this.status = 'active',
    this.labourApiRole = '',
    this.isPremium = false,
    this.earnedCertificates = const [],
    this.myOffers = const [],
    this.username,
    this.posts,
    this.donations,
    this.connections,
    this.linkedin,
    this.github,
    this.twitter,
  }) : assert(
         username == null || username.isEmpty || username.length <= 15,
         'Username must be 15 characters or less',
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = _mongoIdOrString(json['id'] ?? json['_id']);
    final fullName = (json['fullName'] ??
            json['full_name'] ??
            json['name'] ??
            '')
        .toString();
    final email = (json['email'] ?? '').toString();
    final age = _parseAge(json['age']);
    final gender = (json['gender'] ?? '').toString();
    final location = (json['location'] ?? json['address'] ?? '').toString();
    final phoneNumber = (json['phoneNumber'] ??
            json['phone_number'] ??
            json['phone'] ??
            '')
        .toString();
    final profilePic = (json['profilePic'] ?? json['profile_pic'])?.toString();
    final portfolio = (json['portfolio'])?.toString();
    final resume = (json['resume'])?.toString();
    final verified = json['verified'] == true;
    final ratings = (json['ratings'] as num?)?.toDouble() ?? 0.0;
    final reviewsRaw = json['reviews'];
    final reviewsCount = reviewsRaw is num ? reviewsRaw.toInt() : 0;
    final isPremium = json['is_premium'] == true;

    final offeringRaw = json['offeringSkills'] ?? json['offering_skills'] ?? [];
    var offeringSkills = offeringRaw is List
        ? offeringRaw
              .map(_skillToDisplayName)
              .where((s) => s.isNotEmpty)
              .toList()
        : <String>[];
    if (offeringSkills.isEmpty) {
      final selectedRaw =
          json['selectedServices'] ?? json['selected_services'] ?? [];
      if (selectedRaw is List) {
        offeringSkills = selectedRaw
            .map(_skillToDisplayName)
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }
    final learningRaw = json['learningSkills'] ?? json['learning_skills'] ?? [];
    final learningSkills = learningRaw is List
        ? learningRaw
              .map(_skillToDisplayName)
              .where((s) => s.isNotEmpty)
              .toList()
        : <String>[];

    final certsRaw =
        json['earnedCertificates'] ?? json['earned_certificates'] ?? [];
    final earnedCertificates = certsRaw is List
        ? certsRaw.map((e) => e.toString()).toList()
        : <String>[];

    String portfolioLink = '';
    if (portfolio != null && portfolio.isNotEmpty) {
      portfolioLink = portfolio.startsWith('http')
          ? portfolio
          : '${ApiService.activeAssetBaseUrl}$portfolio';
    }

    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      password: '',
      age: age,
      gender: gender,
      location: location,
      phoneNumber: phoneNumber,
      portfolioLink: portfolioLink,
      verified: verified,
      bio: _str(json['bio']),
      profilePic: profilePic,
      education: _str(json['education']),
      offeringSkills: offeringSkills,
      learningSkills: learningSkills,
      pastExperience: _str(json['pastExperience'] ?? json['past_experience']),
      resume: resume,
      portfolio: portfolio,
      cnicFront: _str(json['cnicFront'] ?? json['cnic_front']),
      cnicBack: _str(json['cnicBack'] ?? json['cnic_back']),
      timeCoins:
          (json['timeCoins'] ?? json['time_coins'] as num?)?.toInt() ?? 0,
      subscriptionPackage:
          (json['subscriptionPackage'] ?? json['subscription_package'])
              ?.toString(),
      ratings: ratings,
      reviewsCount: reviewsCount,
      status: (json['status'] ?? 'active').toString(),
      labourApiRole: (json['role'] ?? '').toString(),
      isPremium: isPremium,
      earnedCertificates: earnedCertificates,
      myOffers: const [],
    );
  }

  static int _parseAge(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  String get name => fullName;
  String get profileImage => profilePic ?? '';

  String get profileImageUrl {
    final p = profilePic;
    if (p == null || p.isEmpty) return '';
    if (p.startsWith('http')) return p;
    return '${ApiService.activeAssetBaseUrl}$p';
  }

  String get portfolioFileUrl {
    if (portfolio == null || portfolio!.isEmpty) return portfolioLink;
    if (portfolio!.startsWith('http')) return portfolio!;
    return '${ApiService.activeAssetBaseUrl}$portfolio';
  }

  String get resumeFileUrl {
    final r = resume;
    if (r == null || r.isEmpty) return '';
    if (r.startsWith('http')) return r;
    return '${ApiService.activeAssetBaseUrl}$r';
  }

  String get cnicFrontUrl {
    final p = cnicFront;
    if (p == null || p.isEmpty) return '';
    if (p.startsWith('http')) return p;
    final path = p.startsWith('/') ? p : '/$p';
    return '${ApiService.activeAssetBaseUrl}$path';
  }

  String get cnicBackUrl {
    final p = cnicBack;
    if (p == null || p.isEmpty) return '';
    if (p.startsWith('http')) return p;
    final path = p.startsWith('/') ? p : '/$p';
    return '${ApiService.activeAssetBaseUrl}$path';
  }

  String get labourRoleLower => labourApiRole.trim().toLowerCase();

  bool get isLabourWorkerRole {
    switch (labourRoleLower) {
      case 'worker':
      case 'provider':
      case 'labour':
      case 'service_provider':
        return true;
      default:
        return false;
    }
  }

  List<String> get earnedCertificateUrls => earnedCertificates
      .map(
        (p) => p.startsWith('http') ? p : '${ApiService.activeAssetBaseUrl}$p',
      )
      .toList();
  bool get isVerified => verified;
  String get phone => phoneNumber;

  String get displayUsername {
    if (username != null && username!.isNotEmpty) {
      return username!.length > 15 ? username!.substring(0, 15) : username!;
    }
    final emailUsername = email.split('@')[0];
    return emailUsername.length > 15
        ? emailUsername.substring(0, 15)
        : emailUsername;
  }
}

class Review {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String reviewerProfilePic;
  final double rating;
  final String comment;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerProfilePic,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });
}
