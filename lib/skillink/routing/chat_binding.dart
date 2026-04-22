import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/chat_summary.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

final chatBindingProvider = Provider<int>((ref) {
  final notifiedAt = <String, int>{};

  StreamSubscription<List<ChatSummary>>? sub;
  ref.onDispose(() => unawaited(sub?.cancel()));

  void rebind(String? me) {
    sub?.cancel();
    sub = null;
    if (me == null || me.isEmpty) return;
    final repo = ref.read(chatRepositoryProvider);
    final notifications = ref.read(localNotificationsServiceProvider);

    sub = repo.watchUserChats(me).listen((summaries) {
      final currentChat = ref.read(currentChatIdProvider);
      for (final s in summaries) {
        final lastMs = s.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        if (lastMs == 0) continue;
        final seen = notifiedAt[s.chatId] ?? 0;
        if (lastMs <= seen) continue;
        notifiedAt[s.chatId] = lastMs;

        if (seen == 0) continue;

        if (s.chatId == currentChat) continue;
        if (s.unreadCount <= 0) continue;

        unawaited(notifications.showChatMessage(
          chatId: s.chatId,
          senderName: s.peerName.isEmpty ? 'New message' : s.peerName,
          preview: s.lastMessagePreview ?? '',
        ));
      }
    });
  }

  ref.listen<({bool bootstrapping, String? userId})>(
    authViewModelProvider.select(
      (s) => (
        bootstrapping: s.bootstrapping,
        userId: s.isAuthenticated ? s.user?.id : null,
      ),
    ),
    (prev, next) {
      if (prev?.userId != next.userId) notifiedAt.clear();
      if (next.bootstrapping) {
        sub?.cancel();
        sub = null;
        return;
      }
      rebind(next.userId);
    },
    fireImmediately: true,
  );

  return 0;
});
