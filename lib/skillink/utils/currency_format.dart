/// Formats a numeric amount as `PKR X,XXX`. Negative values are clamped to 0.
String formatPkr(num? amount) {
  final n = amount ?? 0;
  if (n <= 0) return 'PKR 0';
  final i = n.toInt();
  final s = i.toString();
  final buf = StringBuffer();
  for (var idx = 0; idx < s.length; idx++) {
    if (idx > 0 && (s.length - idx) % 3 == 0) buf.write(',');
    buf.write(s[idx]);
  }
  return 'PKR $buf';
}
