import 'dart:io';

import 'package:skilllink/models/chat_models.dart' as sc;
import 'package:skilllink/services/chat/chat_service.dart' as sc;
import 'package:skilllink/skillink/data/repositories/chat_repository.dart';
import 'package:skilllink/skillink/domain/models/chat_message.dart';
import 'package:skilllink/skillink/domain/models/chat_summary.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/utils/result.dart';

class SocketIoChatRepository implements ChatRepository {
  SocketIoChatRepository({required sc.ChatService chatService})
      : _chat = chatService;

  final sc.ChatService _chat;

  @override
  Stream<List<ChatSummary>> watchUserChats(String userId) async* {
    await _chat.initialize();
    yield* _chat.watchConversations().map(
          (list) => list.map(_summaryFromPreview).toList(),
        );
  }

  @override
  Stream<List<ChatMessage>> watchMessages(
    String chatId, {
    required int limit,
  }) async* {
    await _chat.initialize();
    yield* _chat.watchMessages(chatId).map(
          (list) => list
              .map((m) => _messageFromModel(m, chatId))
              .toList(),
        );
  }

  @override
  Future<Result<List<ChatMessage>>> loadMessagesBefore({
    required String chatId,
    required DateTime before,
    required int limit,
  }) async {
    return const Success(<ChatMessage>[]);
  }

  @override
  Future<Result<OpenedChat>> openChat(OpenChatInput input) async {
    try {
      final roomId = await _chat.openOrCreateConversation(
        participantId: input.peerId,
        participantName: input.peerName,
        participantAvatar: input.peerAvatar ?? '',
        participantOnline: false,
      );
      final summary = ChatSummary(
        chatId: roomId,
        peerId: input.peerId,
        peerName: input.peerName,
        peerAvatar: input.peerAvatar,
        peerRole: input.peerRole,
        unreadCount: 0,
      );
      return Success(OpenedChat(chatId: roomId, summary: summary));
    } on Exception catch (e) {
      return Failure('Could not open chat.', e);
    }
  }

  @override
  Future<Result<ChatMessage>> sendText({
    required String chatId,
    required String senderId,
    required String peerId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const Failure('Message cannot be empty.');
    }
    try {
      await _chat.sendMessage(
        conversationId: chatId,
        text: trimmed,
        recipientUserId: peerId,
      );
      return Success(
        ChatMessage(
          messageId: 'pending_${DateTime.now().microsecondsSinceEpoch}',
          chatId: chatId,
          senderId: senderId,
          type: ChatMessageType.text,
          text: trimmed,
          sentAt: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      return Failure('Could not send message.', e);
    }
  }

  @override
  Future<Result<ChatMessage>> sendImage({
    required String chatId,
    required String senderId,
    required String peerId,
    required File imageFile,
  }) async {
    return const Failure(
      'Image messages are not yet supported on the SkillChain chat backend.',
    );
  }

  @override
  Future<Result<ChatMessage>> sendAudio({
    required String chatId,
    required String senderId,
    required String peerId,
    required File audioFile,
    required int durationMs,
  }) async {
    return const Failure(
      'Voice notes are not yet supported on the SkillChain chat backend.',
    );
  }

  @override
  Future<Result<void>> markRead({
    required String chatId,
    required String viewerId,
  }) async {
    try {
      await _chat.markConversationAsRead(chatId);
      return const Success(null);
    } on Exception catch (e) {
      return Failure('Could not mark as read.', e);
    }
  }

  ChatSummary _summaryFromPreview(sc.ChatConversationPreview p) {
    return ChatSummary(
      chatId: p.id,
      peerId: p.participantId,
      peerName: p.participantName,
      peerAvatar: p.participantAvatar.isEmpty ? null : p.participantAvatar,
      peerRole: UserRole.homeowner,
      lastMessagePreview: p.lastMessage.isEmpty ? null : p.lastMessage,
      lastMessageType:
          p.lastMessage.isEmpty ? null : ChatMessageType.text,
      lastMessageAt: p.lastMessage.isEmpty ? null : p.lastMessageTime,
      unreadCount: p.unreadCount,
    );
  }

  ChatMessage _messageFromModel(sc.ChatMessageModel m, String chatId) {
    return ChatMessage(
      messageId: m.id,
      chatId: chatId,
      senderId: m.senderId,
      type: ChatMessageType.text,
      text: m.text,
      sentAt: m.timestamp,
    );
  }
}
