enum ChatMessageStatus { sending, sent, delivered, read, failed }

enum ChatConnectionStatus { disconnected, connecting, connected }

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final ChatMessageStatus status;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.status = ChatMessageStatus.sent,
  });

  bool isFrom(String userId) => senderId == userId;

  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    ChatMessageStatus? status,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}

class ChatConversationPreview {
  final String id;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool participantOnline;
  final int unreadCount;
  final bool isMyLastMessage;

  const ChatConversationPreview({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.participantOnline = false,
    this.unreadCount = 0,
    this.isMyLastMessage = false,
  });

  ChatConversationPreview copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? participantOnline,
    int? unreadCount,
    bool? isMyLastMessage,
  }) {
    return ChatConversationPreview(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      participantOnline: participantOnline ?? this.participantOnline,
      unreadCount: unreadCount ?? this.unreadCount,
      isMyLastMessage: isMyLastMessage ?? this.isMyLastMessage,
    );
  }
}
