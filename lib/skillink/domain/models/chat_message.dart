import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum ChatMessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('audio')
  audio,
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String messageId,
    required String chatId,
    required String senderId,
    required ChatMessageType type,
    String? text,
    String? imageUrl,
    String? audioUrl,
    int? audioDurationMs,
    required DateTime sentAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
