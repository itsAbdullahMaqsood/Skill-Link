enum JobMediaType {
  photo,
  video,
}

extension JobMediaTypeX on JobMediaType {
  String get wireName => name;

  static JobMediaType parse(String? raw) {
    if (raw == null || raw.isEmpty) return JobMediaType.photo;
    return JobMediaType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => JobMediaType.photo,
    );
  }
}
