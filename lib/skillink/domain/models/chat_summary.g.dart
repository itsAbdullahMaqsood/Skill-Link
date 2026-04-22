// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatSummary _$ChatSummaryFromJson(Map<String, dynamic> json) => _ChatSummary(
  chatId: json['chatId'] as String,
  peerId: json['peerId'] as String,
  peerName: json['peerName'] as String,
  peerAvatar: json['peerAvatar'] as String?,
  peerRole: $enumDecode(_$UserRoleEnumMap, json['peerRole']),
  lastMessagePreview: json['lastMessagePreview'] as String?,
  lastMessageType: $enumDecodeNullable(
    _$ChatMessageTypeEnumMap,
    json['lastMessageType'],
  ),
  lastMessageAt: json['lastMessageAt'] == null
      ? null
      : DateTime.parse(json['lastMessageAt'] as String),
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ChatSummaryToJson(_ChatSummary instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'peerId': instance.peerId,
      'peerName': instance.peerName,
      'peerAvatar': instance.peerAvatar,
      'peerRole': _$UserRoleEnumMap[instance.peerRole]!,
      'lastMessagePreview': instance.lastMessagePreview,
      'lastMessageType': _$ChatMessageTypeEnumMap[instance.lastMessageType],
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'unreadCount': instance.unreadCount,
    };

const _$UserRoleEnumMap = {
  UserRole.homeowner: 'homeowner',
  UserRole.worker: 'worker',
};

const _$ChatMessageTypeEnumMap = {
  ChatMessageType.text: 'text',
  ChatMessageType.image: 'image',
  ChatMessageType.audio: 'audio',
};
