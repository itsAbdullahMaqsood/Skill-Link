import 'dart:io';

import 'package:skilllink/skillink/domain/models/chat_message.dart';
import 'package:skilllink/skillink/domain/models/chat_summary.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/utils/result.dart';

class OpenChatInput {
  const OpenChatInput({
    required this.viewerId,
    required this.viewerName,
    required this.viewerRole,
    this.viewerAvatar,
    required this.peerId,
    required this.peerName,
    required this.peerRole,
    this.peerAvatar,
    this.relatedJobId,
  });

  final String viewerId;
  final String viewerName;
  final UserRole viewerRole;
  final String? viewerAvatar;
  final String peerId;
  final String peerName;
  final UserRole peerRole;
  final String? peerAvatar;
  final String? relatedJobId;
}

class OpenedChat {
  const OpenedChat({required this.chatId, required this.summary});

  final String chatId;
  final ChatSummary summary;
}

abstract class ChatRepository {
  Stream<List<ChatSummary>> watchUserChats(String userId);

  Stream<List<ChatMessage>> watchMessages(String chatId, {required int limit});

  Future<Result<List<ChatMessage>>> loadMessagesBefore({
    required String chatId,
    required DateTime before,
    required int limit,
  });

  Future<Result<OpenedChat>> openChat(OpenChatInput input);

  Future<Result<ChatMessage>> sendText({
    required String chatId,
    required String senderId,
    required String peerId,
    required String text,
  });

  Future<Result<ChatMessage>> sendImage({
    required String chatId,
    required String senderId,
    required String peerId,
    required File imageFile,
  });

  Future<Result<ChatMessage>> sendAudio({
    required String chatId,
    required String senderId,
    required String peerId,
    required File audioFile,
    required int durationMs,
  });

  Future<Result<void>> markRead({
    required String chatId,
    required String viewerId,
  });
}
