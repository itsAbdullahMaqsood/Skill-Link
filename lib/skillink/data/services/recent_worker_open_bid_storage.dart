import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilllink/skillink/domain/models/open_job_post_bid.dart';

/// Locally persisted row for "My Recent Bids" when the API list is empty or
/// posts have left the open-for-bids state.
class LocalRecentOpenJobBid {
  const LocalRecentOpenJobBid({
    required this.postId,
    required this.descriptionPreview,
    required this.amount,
    required this.currency,
    required this.status,
    required this.recordedAt,
  });

  final String postId;
  final String descriptionPreview;
  final num amount;
  final String currency;
  final OpenJobPostBidStatus status;
  final DateTime recordedAt;

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'descriptionPreview': descriptionPreview,
        'amount': amount,
        'currency': currency,
        'status': _statusToRaw(status),
        'recordedAt': recordedAt.toIso8601String(),
      };

  factory LocalRecentOpenJobBid.fromJson(Map<String, dynamic> j) {
    return LocalRecentOpenJobBid(
      postId: (j['postId'] ?? '').toString(),
      descriptionPreview: (j['descriptionPreview'] ?? '').toString(),
      amount: j['amount'] is num ? j['amount'] as num : num.tryParse('${j['amount']}') ?? 0,
      currency: (j['currency'] ?? 'PKR').toString(),
      status: OpenJobPostBidStatus.fromRaw(j['status'] as String?),
      recordedAt: DateTime.tryParse((j['recordedAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  static String _statusToRaw(OpenJobPostBidStatus s) => switch (s) {
        OpenJobPostBidStatus.pending => 'pending',
        OpenJobPostBidStatus.accepted => 'accepted',
        OpenJobPostBidStatus.rejected => 'rejected',
        OpenJobPostBidStatus.withdrawn => 'withdrawn',
        OpenJobPostBidStatus.unknown => 'unknown',
      };
}

abstract final class RecentWorkerOpenBidStorage {
  static const _keyPrefix = 'skillink_recent_worker_open_bids_v1_';
  static const _maxEntries = 24;

  static String _key(String workerUserId) => '$_keyPrefix$workerUserId';

  static String _truncate(String text, int maxLen) {
    final t = text.trim();
    if (t.length <= maxLen) return t.isEmpty ? 'Open job' : t;
    return '${t.substring(0, maxLen)}…';
  }

  static Future<List<LocalRecentOpenJobBid>> load(String workerUserId) async {
    if (workerUserId.isEmpty) return const [];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(workerUserId));
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => LocalRecentOpenJobBid.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.postId.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> record({
    required String workerUserId,
    required String postId,
    required String description,
    required num amount,
    required String currency,
    required OpenJobPostBidStatus status,
  }) async {
    if (workerUserId.isEmpty || postId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = await load(workerUserId);
    final entry = LocalRecentOpenJobBid(
      postId: postId,
      descriptionPreview: _truncate(description, 140),
      amount: amount,
      currency: currency,
      status: status,
      recordedAt: DateTime.now().toUtc(),
    );
    final merged = <LocalRecentOpenJobBid>[
      entry,
      ...existing.where((e) => e.postId != postId),
    ].take(_maxEntries).toList();
    await prefs.setString(
      _key(workerUserId),
      jsonEncode(merged.map((e) => e.toJson()).toList()),
    );
  }
}
