import 'package:skilllink/models/user.dart' as sc;
import 'package:skilllink/skillink/domain/models/worker.dart';

class WorkerFromSkillChainUser {
  WorkerFromSkillChainUser._();

  static Worker map(sc.UserModel u) {
    var skills = List<String>.from(u.offeringSkills);
    if (skills.isEmpty) {
      skills = List<String>.from(u.learningSkills);
    }
    if (skills.isEmpty) {
      skills = const ['Labour services'];
    }

    double? lat;
    double? lng;
    final loc = u.location.trim();
    if (loc.contains(',')) {
      final parts = loc.split(',');
      if (parts.length >= 2) {
        lat = double.tryParse(parts[0].trim());
        lng = double.tryParse(parts[1].trim());
      }
    }

    final meta = <String>[];
    if (u.age > 0) meta.add('Age ${u.age}');
    if (u.gender.trim().isNotEmpty) meta.add(u.gender);
    if (u.labourApiRole.trim().isNotEmpty) {
      meta.add('Role: ${u.labourApiRole}');
    }
    if (u.status.trim().isNotEmpty) meta.add('Status: ${u.status}');
    final metaLine = meta.isEmpty ? null : meta.join(' · ');

    final bioParts = <String>[];
    if (metaLine != null) bioParts.add(metaLine);
    if (u.bio != null && u.bio!.trim().isNotEmpty) bioParts.add(u.bio!.trim());
    final experienceNote = u.pastExperience?.trim().isEmpty ?? true
        ? null
        : u.pastExperience!.trim();
    final combinedBio = bioParts.isEmpty ? null : bioParts.join('\n\n');

    return Worker(
      id: u.id,
      name: u.fullName.isEmpty ? u.email : u.fullName,
      email: u.email,
      phone: u.phoneNumber,
      skillTypes: skills,
      rating: u.ratings,
      reviewCount: u.reviewsCount,
      verificationStatus: u.verified,
      latitude: lat,
      longitude: lng,
      hourlyRate: null,
      avatarUrl: u.profileImageUrl.isEmpty ? null : u.profileImageUrl,
      bio: combinedBio,
      portfolioUrls: const [],
      experienceYears: null,
      serviceRadiusKm: null,
      role: u.labourApiRole.trim().isEmpty ? null : u.labourApiRole.trim(),
      accountStatus: u.status.trim().isEmpty ? null : u.status.trim(),
      experienceNote: experienceNote,
    );
  }
}
