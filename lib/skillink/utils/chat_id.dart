import 'dart:convert';

String chatIdFor(String uidA, String uidB) {
  if (uidA.isEmpty || uidB.isEmpty) {
    throw ArgumentError('Both uids must be non-empty.');
  }
  final ids = [uidA, uidB]..sort();
  final a = _enc(ids[0]);
  final b = _enc(ids[1]);
  return 'c_${a}__$b';
}

String _enc(String uid) =>
    base64Url.encode(utf8.encode(uid)).replaceAll('=', '');

String? peerIdFor(String chatId, String myId) {
  if (myId.isEmpty || !chatId.startsWith('c_')) return null;
  final body = chatId.substring(2);
  final sep = body.indexOf('__');
  if (sep <= 0 || sep >= body.length - 2) return null;
  final left = _dec(body.substring(0, sep));
  final right = _dec(body.substring(sep + 2));
  if (left == null || right == null) return null;
  if (left == myId) return right;
  if (right == myId) return left;
  return null;
}

String? _dec(String segment) {
  if (segment.isEmpty) return null;
  try {
    final padded = segment + '=' * ((4 - segment.length % 4) % 4);
    return utf8.decode(base64Url.decode(padded));
  } catch (_) {
    return null;
  }
}
