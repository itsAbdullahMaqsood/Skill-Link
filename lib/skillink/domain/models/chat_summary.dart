import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skilllink/skillink/domain/models/chat_message.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';

part 'chat_summary.freezed.dart';
part 'chat_summary.g.dart';

@freezed
abstract class ChatSummary with _$ChatSummary {
  const factory ChatSummary({
    required String chatId,
    required String peerId,
    required String peerName,
    String? peerAvatar,
    required UserRole peerRole,

    String? lastMessagePreview,
    ChatMessageType? lastMessageType,
    DateTime? lastMessageAt,
    @Default(0) int unreadCount,
  }) = _ChatSummary;

  factory ChatSummary.fromJson(Map<String, dynamic> json) =>
      _$ChatSummaryFromJson(json);
}
