class TextFormat {
  TextFormat._();

  static String titleCase(String s) {
    if (s.isEmpty) return s;
    return s
        .split(RegExp(r'[\s_\-]'))
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
        .join(' ');
  }

  static String trade(String raw) {
    final lower = raw.toLowerCase().trim();
    if (lower == 'hvac') return 'HVAC';
    if (lower == 'ac') return 'AC';
    return titleCase(raw);
  }
}
