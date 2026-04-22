// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  messageId: json['messageId'] as String,
  chatId: json['chatId'] as String,
  senderId: json['senderId'] as String,
  type: $enumDecode(_$ChatMessageTypeEnumMap, json['type']),
  text: json['text'] as String?,
  imageUrl: json['imageUrl'] as String?,
  audioUrl: json['audioUrl'] as String?,
  audioDurationMs: (json['audioDurationMs'] as num?)?.toInt(),
  sentAt: DateTime.parse(json['sentAt'] as String),
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'type': _$ChatMessageTypeEnumMap[instance.type]!,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'audioUrl': instance.audioUrl,
      'audioDurationMs': instance.audioDurationMs,
      'sentAt': instance.sentAt.toIso8601String(),
    };

const _$ChatMessageTypeEnumMap = {
  ChatMessageType.text: 'text',
  ChatMessageType.image: 'image',
  ChatMessageType.audio: 'audio',
};
