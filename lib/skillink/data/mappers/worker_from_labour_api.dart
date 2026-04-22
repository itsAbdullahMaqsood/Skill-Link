import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';

String _labourId(dynamic raw) {
  if (raw == null) return '';
  if (raw is Map) {
    final oid = raw[r'$oid'] ?? raw['oid'];
    if (oid != null) return oid.toString().trim();
  }
  return raw.toString().trim();
}

String _serviceEntryToId(dynamic e) {
  if (e is Map) {
    final id = e['id'] ?? e['_id'];
    if (id != null) return id.toString().trim();
    final name = e['name'];
    if (name != null) return name.toString().trim();
  }
  if (e is String) return e.trim();
  return e.toString().trim();
}

Map<String, dynamic> coerceLabourWorkerJson(Map<String, dynamic> raw) {
  final j = Map<String, dynamic>.from(raw);
  void copyIfAbsent(String canonical, List<String> aliases) {
    if (j[canonical] != null) return;
    for (final k in aliases) {
      final v = j[k];
      if (v != null) {
        j[canonical] = v;
        return;
      }
    }
  }

  copyIfAbsent('fullName', ['full_name', 'name']);
  copyIfAbsent('selectedServices', ['selected_services']);
  copyIfAbsent('phoneNumber', ['phone_number']);
  copyIfAbsent('pastExperience', ['past_experience']);
  copyIfAbsent('profilePic', ['profile_pic']);
  copyIfAbsent('status', ['account_status']);
  return j;
}

Worker workerFromLabourApiJson(Map<String, dynamic> raw) {
  final json = coerceLabourWorkerJson(raw);

  final profilePic = json['profilePic'] as String?;
  String? avatarUrl;
  if (profilePic != null && profilePic.isNotEmpty) {
    if (profilePic.startsWith('http')) {
      avatarUrl = profilePic;
    } else {
      final p = profilePic.startsWith('/') ? profilePic : '/$profilePic';
      avatarUrl = '${AppConstants.apiBaseUrl}$p';
    }
  }

  final mergedSkillIds = <String>[];
  void addServiceList(List<dynamic>? list) {
    if (list == null) return;
    for (final e in list) {
      final id = _serviceEntryToId(e);
      if (id.isEmpty) continue;
      if (!mergedSkillIds.contains(id)) mergedSkillIds.add(id);
    }
  }

  addServiceList(json['selectedServices'] as List<dynamic>?);
  addServiceList(json['services'] as List<dynamic>?);
  addServiceList(json['skillTypes'] as List<dynamic>?);
  addServiceList(json['skills'] as List<dynamic>?);
  final selectedServices = mergedSkillIds;

  final ratings = (json['ratings'] as num?)?.toDouble() ?? 0.0;
  final reviews = (json['reviews'] as num?)?.toInt() ?? 0;
  final verified = json['verified'] as bool? ?? false;

  final pastExperience = json['pastExperience'];
  int? experienceYears;
  String? experienceNote;
  if (pastExperience is int) {
    experienceYears = pastExperience;
  } else if (pastExperience is num) {
    experienceYears = pastExperience.round();
  } else if (pastExperience is String) {
    final t = pastExperience.trim();
    if (t.isNotEmpty) {
      final n = int.tryParse(t);
      if (n != null) {
        experienceYears = n;
      } else {
        experienceNote = t;
      }
    }
  }

  final roleRaw = json['role'] ?? json['labourApiRole'];
  final role = roleRaw?.toString().trim();
  final statusRaw = json['status'] ?? json['accountStatus'];
  final accountStatus = statusRaw?.toString().trim();

  final fullName = json['fullName'];
  final name = fullName is String && fullName.trim().isNotEmpty
      ? fullName.trim()
      : 'Worker';

  final id = _labourId(json['id'] ?? json['_id']);

  return Worker(
    id: id,
    name: name,
    email: (json['email'] as String?) ?? '',
    phone: (json['phoneNumber'] ?? '').toString(),
    skillTypes: selectedServices,
    rating: ratings,
    reviewCount: reviews,
    verificationStatus: verified,
    avatarUrl: avatarUrl,
    bio: json['bio'] as String?,
    experienceYears: experienceYears,
    role: (role == null || role.isEmpty) ? null : role,
    accountStatus:
        (accountStatus == null || accountStatus.isEmpty) ? null : accountStatus,
    experienceNote: experienceNote,
  );
}
