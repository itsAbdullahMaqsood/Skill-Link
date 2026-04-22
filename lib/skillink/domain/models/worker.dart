import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skilllink/skillink/domain/models/app_user.dart';
import 'package:skilllink/skillink/utils/text_format.dart';

part 'worker.freezed.dart';
part 'worker.g.dart';

@freezed
abstract class Worker with _$Worker {
  const factory Worker({
    required String id,
    required String name,
    required String email,
    required String phone,
    required List<String> skillTypes,
    required double rating,
    required int reviewCount,
    required bool verificationStatus,
    double? latitude,
    double? longitude,
    double? hourlyRate,
    String? avatarUrl,
    String? bio,
    double? distanceKm,
    @Default(<String>[]) List<String> portfolioUrls,
    int? experienceYears,
    double? serviceRadiusKm,
    String? role,
    String? accountStatus,
    String? experienceNote,
  }) = _Worker;

  factory Worker.fromJson(Map<String, dynamic> json) =>
      _$WorkerFromJson(json);

  factory Worker.fromAppUser(
    AppUser user, {
    required List<String> skillTypes,
    double rating = 0.0,
    int reviewCount = 0,
    bool verificationStatus = false,
    double? hourlyRate,
    double? latitude,
    double? longitude,
    String? bio,
    List<String> portfolioUrls = const <String>[],
    int? experienceYears,
    double? serviceRadiusKm,
    String? role,
    String? accountStatus,
    String? experienceNote,
  }) {
    return Worker(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      skillTypes: skillTypes,
      rating: rating,
      reviewCount: reviewCount,
      verificationStatus: verificationStatus,
      hourlyRate: hourlyRate,
      latitude: latitude,
      longitude: longitude,
      avatarUrl: user.avatarUrl,
      bio: bio,
      portfolioUrls: portfolioUrls,
      experienceYears: experienceYears,
      serviceRadiusKm: serviceRadiusKm,
      role: role,
      accountStatus: accountStatus,
      experienceNote: experienceNote,
    );
  }
}

bool _isOpaqueServiceId(String s) =>
    s.length >= 15 && RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(s);

String _fallbackServiceLabel(String id) {
  if (!_isOpaqueServiceId(id)) return TextFormat.trade(id);
  final tail = id.length > 6 ? id.substring(id.length - 6) : id;
  return 'Skill ··$tail';
}

List<String> resolveWorkerServiceLabels(
  Worker w, {
  Map<String, String>? idToName,
}) {
  if (w.skillTypes.isEmpty) return const ['Technician'];
  final map = idToName ?? const {};
  return w.skillTypes.map((id) {
    final name = map[id];
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return _fallbackServiceLabel(id);
  }).toList();
}

extension WorkerTrade on Worker {
  List<String> get serviceDisplayLabels =>
      resolveWorkerServiceLabels(this, idToName: null);

  String get primaryTrade =>
      serviceDisplayLabels.isEmpty ? 'Technician' : serviceDisplayLabels.first;
}
