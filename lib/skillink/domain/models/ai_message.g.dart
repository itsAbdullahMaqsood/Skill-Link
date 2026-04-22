// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiSource _$AiSourceFromJson(Map<String, dynamic> json) =>
    _AiSource(title: json['title'] as String, url: json['url'] as String);

Map<String, dynamic> _$AiSourceToJson(_AiSource instance) => <String, dynamic>{
  'title': instance.title,
  'url': instance.url,
};

_AiMessage _$AiMessageFromJson(Map<String, dynamic> json) => _AiMessage(
  id: json['id'] as String,
  role: $enumDecode(_$AiMessageRoleEnumMap, json['role']),
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  sources:
      (json['sources'] as List<dynamic>?)
          ?.map((e) => AiSource.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  recommendedWorker: json['recommendedWorker'] == null
      ? null
      : Worker.fromJson(json['recommendedWorker'] as Map<String, dynamic>),
  suggestedTrade: json['suggestedTrade'] as String?,
);

Map<String, dynamic> _$AiMessageToJson(_AiMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$AiMessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'sources': instance.sources,
      'recommendedWorker': instance.recommendedWorker,
      'suggestedTrade': instance.suggestedTrade,
    };

const _$AiMessageRoleEnumMap = {
  AiMessageRole.user: 'user',
  AiMessageRole.ai: 'ai',
};
