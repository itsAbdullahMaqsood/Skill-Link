import 'dart:async';
import 'dart:io';

import 'package:skilllink/skillink/data/repositories/chat_repository.dart';
import 'package:skilllink/skillink/domain/models/chat_message.dart';
import 'package:skilllink/skillink/domain/models/chat_summary.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/utils/chat_id.dart';
import 'package:skilllink/skillink/utils/result.dart';

class FakeChatRepository implements ChatRepository {
  FakeChatRepository();

  final Map<String, List<ChatMessage>> _messages = {};
  final Map<String, Map<String, ChatSummary>> _index =
      {};
  final Map<String, StreamController<List<ChatSummary>>> _userStreams = {};
  final Map<String, StreamController<List<ChatMessage>>> _msgStreams = {};

  final Map<String, int> _msgLimits = {};

  bool _seeded = false;

  static const _latency = Duration(milliseconds: 250);

  void _seedIfNeeded(String currentUserId) {
    if (_seeded) return;
    _seeded = true;

    const homeowner = (
      id: 'homeowner_001',
      name: 'Ahmad Khan',
      avatar: null as String?,
      role: UserRole.homeowner,
    );
    const worker = (
      id: 'worker_001',
      name: 'Ali Raza',
      avatar: null as String?,
      role: UserRole.worker,
    );

    final chatId = chatIdFor(homeowner.id, worker.id);
    final now = DateTime.now();
    final seedMessages = [
      ChatMessage(
        messageId: 'seed_msg_1',
        chatId: chatId,
        senderId: homeowner.id,
        type: ChatMessageType.text,
        text: 'Hi! Are you available this weekend for an AC service?',
        sentAt: now.subtract(const Duration(hours: 3, minutes: 12)),
      ),
      ChatMessage(
        messageId: 'seed_msg_2',
        chatId: chatId,
        senderId: worker.id,
        type: ChatMessageType.text,
        text: 'Yes sir, I can come Saturday morning. What model is the AC?',
        sentAt: now.subtract(const Duration(hours: 3, minutes: 5)),
      ),
      ChatMessage(
        messageId: 'seed_msg_3',
        chatId: chatId,
        senderId: homeowner.id,
        type: ChatMessageType.text,
        text: "It's a Haier 1.5-ton inverter, about 4 years old. Cooling is weak.",
        sentAt: now.subtract(const Duration(hours: 2, minutes: 50)),
      ),
    ];
    _messages[chatId] = seedMessages;

    _index[homeowner.id] ??= {};
    _index[worker.id] ??= {};

    final last = seedMessages.last;
    _index[homeowner.id]![chatId] = ChatSummary(
      chatId: chatId,
      peerId: worker.id,
      peerName: worker.name,
      peerAvatar: worker.avatar,
      peerRole: worker.role,
      lastMessagePreview: last.text,
      lastMessageType: last.type,
      lastMessageAt: last.sentAt,
    );
    _index[worker.id]![chatId] = ChatSummary(
      chatId: chatId,
      peerId: homeowner.id,
      peerName: homeowner.name,
      peerAvatar: homeowner.avatar,
      peerRole: homeowner.role,
      lastMessagePreview: last.text,
      lastMessageType: last.type,
      lastMessageAt: last.sentAt,
      unreadCount: 1,
    );

    _index[currentUserId] ??= {};
  }

  StreamController<List<ChatSummary>> _userStream(String userId) =>
      _userStreams.putIfAbsent(
        userId,
        () => StreamController<List<ChatSummary>>.broadcast(),
      );

  StreamController<List<ChatMessage>> _msgStream(String chatId) =>
      _msgStreams.putIfAbsent(
        chatId,
        () => StreamController<List<ChatMessage>>.broadcast(),
      );

  void _emitUser(String userId) {
    final entries = _index[userId]?.values.toList() ?? <ChatSummary>[];
    entries.sort((a, b) {
      final aT = a.lastMessageAt?.millisecondsSinceEpoch ?? 0;
      final bT = b.lastMessageAt?.millisecondsSinceEpoch ?? 0;
      return bT.compareTo(aT);
    });
    _userStream(userId).add(entries);
  }

  void _emitMessages(String chatId) {
    final list = List<ChatMessage>.of(_messages[chatId] ?? const [])
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    final limit = _msgLimits[chatId];
    final clipped = (limit != null && list.length > limit)
        ? list.sublist(list.length - limit)
        : list;
    _msgStream(chatId).add(clipped);
  }


  @override
  Stream<List<ChatSummary>> watchUserChats(String userId) {
    _seedIfNeeded(userId);
    final controller = _userStream(userId);
    scheduleMicrotask(() => _emitUser(userId));
    return controller.stream;
  }

  @override
  String? cachedPeerIdForChat(String chatId, String viewerId) {
    _seedIfNeeded(viewerId);
    return _index[viewerId]?[chatId]?.peerId;
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId, {required int limit}) {
    final existing = _msgLimits[chatId] ?? 0;
    if (limit > existing) _msgLimits[chatId] = limit;
    final controller = _msgStream(chatId);
    scheduleMicrotask(() {
      final list = List<ChatMessage>.of(_messages[chatId] ?? const [])
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      final start = list.length > limit ? list.length - limit : 0;
      controller.add(list.sublist(start));
    });
    return controller.stream;
  }

  @override
  Future<Result<List<ChatMessage>>> loadMessagesBefore({
    required String chatId,
    required DateTime before,
    required int limit,
  }) async {
    await Future<void>.delayed(_latency);
    final all = List<ChatMessage>.of(_messages[chatId] ?? const [])
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    final older = all.where((m) => m.sentAt.isBefore(before)).toList();
    final start = older.length > limit ? older.length - limit : 0;
    return Success(older.sublist(start));
  }

  @override
  Future<Result<OpenedChat>> openChat(OpenChatInput input) async {
    await Future<void>.delayed(_latency);
    _seedIfNeeded(input.viewerId);
    final chatId = chatIdFor(input.viewerId, input.peerId);

    _index[input.viewerId] ??= {};
    _index[input.peerId] ??= {};

    final viewerEntry = _index[input.viewerId]![chatId];
    if (viewerEntry == null) {
      _index[input.viewerId]![chatId] = ChatSummary(
        chatId: chatId,
        peerId: input.peerId,
        peerName: input.peerName,
        peerAvatar: input.peerAvatar,
        peerRole: input.peerRole,
      );
    }
    final peerEntry = _index[input.peerId]![chatId];
    if (peerEntry == null) {
      _index[input.peerId]![chatId] = ChatSummary(
        chatId: chatId,
        peerId: input.viewerId,
        peerName: input.viewerName,
        peerAvatar: input.viewerAvatar,
        peerRole: input.viewerRole,
      );
    }

    _emitUser(input.viewerId);
    _emitUser(input.peerId);

    return Success(OpenedChat(
      chatId: chatId,
      summary: _index[input.viewerId]![chatId]!,
    ));
  }

  ChatMessage _appendMessage({
    required String chatId,
    required String senderId,
    required String peerId,
    required ChatMessageType type,
    String? text,
    String? imageUrl,
    String? audioUrl,
    int? audioDurationMs,
  }) {
    final now = DateTime.now();
    final msg = ChatMessage(
      messageId: 'msg_${now.microsecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      type: type,
      text: text,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      audioDurationMs: audioDurationMs,
      sentAt: now,
    );
    _messages.putIfAbsent(chatId, () => []).add(msg);

    final preview = switch (type) {
      ChatMessageType.text => (text ?? '').trim(),
      ChatMessageType.image => '[Image]',
      ChatMessageType.audio => '[Voice note]',
    };

    final senderIdx = _index[senderId]?[chatId];
    if (senderIdx != null) {
      _index[senderId]![chatId] = senderIdx.copyWith(
        lastMessagePreview: preview,
        lastMessageType: type,
        lastMessageAt: now,
      );
    }
    final peerIdx = _index[peerId]?[chatId];
    if (peerIdx != null) {
      _index[peerId]![chatId] = peerIdx.copyWith(
        lastMessagePreview: preview,
        lastMessageType: type,
        lastMessageAt: now,
        unreadCount: peerIdx.unreadCount + 1,
      );
    }

    _emitMessages(chatId);
    _emitUser(senderId);
    _emitUser(peerId);

    return msg;
  }

  @override
  Future<Result<ChatMessage>> sendText({
    required String chatId,
    required String senderId,
    required String peerId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const Failure('Message cannot be empty.');
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return Success(_appendMessage(
      chatId: chatId,
      senderId: senderId,
      peerId: peerId,
      type: ChatMessageType.text,
      text: trimmed,
    ));
  }

  @override
  Future<Result<ChatMessage>> sendImage({
    required String chatId,
    required String senderId,
    required String peerId,
    required File imageFile,
  }) async {
    await Future<void>.delayed(_latency);
    return Success(_appendMessage(
      chatId: chatId,
      senderId: senderId,
      peerId: peerId,
      type: ChatMessageType.image,
      imageUrl: Uri.file(imageFile.path).toString(),
    ));
  }

  @override
  Future<Result<ChatMessage>> sendAudio({
    required String chatId,
    required String senderId,
    required String peerId,
    required File audioFile,
    required int durationMs,
  }) async {
    await Future<void>.delayed(_latency);
    return Success(_appendMessage(
      chatId: chatId,
      senderId: senderId,
      peerId: peerId,
      type: ChatMessageType.audio,
      audioUrl: Uri.file(audioFile.path).toString(),
      audioDurationMs: durationMs,
    ));
  }

  @override
  Future<Result<void>> markRead({
    required String chatId,
    required String viewerId,
  }) async {
    final entry = _index[viewerId]?[chatId];
    if (entry != null && entry.unreadCount != 0) {
      _index[viewerId]![chatId] = entry.copyWith(unreadCount: 0);
      _emitUser(viewerId);
    }
    return const Success(null);
  }

  Future<void> dispose() async {
    for (final c in _userStreams.values) {
      await c.close();
    }
    for (final c in _msgStreams.values) {
      await c.close();
    }
    _userStreams.clear();
    _msgStreams.clear();
  }
}
