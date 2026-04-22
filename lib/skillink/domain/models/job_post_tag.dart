enum JobPostTag {
  electrician,
  plumber,
  hvac,
  carpenter,
  cleaner,
  painter,
  applianceRepair,
  other,
}

extension JobPostTagX on JobPostTag {
  String get wireName => switch (this) {
        JobPostTag.applianceRepair => 'applianceRepair',
        _ => name,
      };

  String get serviceTypeSlug => switch (this) {
        JobPostTag.electrician => 'electrician',
        JobPostTag.plumber => 'plumber',
        JobPostTag.hvac => 'hvac',
        JobPostTag.carpenter => 'carpenter',
        JobPostTag.cleaner => 'cleaner',
        JobPostTag.painter => 'painter',
        JobPostTag.applianceRepair => 'electrician',
        JobPostTag.other => 'carpenter',
      };

  static JobPostTag parse(String? raw) {
    if (raw == null || raw.isEmpty) return JobPostTag.other;
    return JobPostTag.values.firstWhere(
      (e) => e.wireName == raw || e.name == raw,
      orElse: () => JobPostTag.other,
    );
  }
}
