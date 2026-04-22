import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';

part 'ai_message.freezed.dart';
part 'ai_message.g.dart';

enum AiMessageRole { user, ai }

@freezed
abstract class AiSource with _$AiSource {
  const factory AiSource({
    required String title,
    required String url,
  }) = _AiSource;

  factory AiSource.fromJson(Map<String, dynamic> json) =>
      _$AiSourceFromJson(json);
}

@freezed
abstract class AiMessage with _$AiMessage {
  const factory AiMessage({
    required String id,
    required AiMessageRole role,
    required String content,
    required DateTime createdAt,
    @Default([]) List<AiSource> sources,
    Worker? recommendedWorker,
    String? suggestedTrade,
  }) = _AiMessage;

  factory AiMessage.fromJson(Map<String, dynamic> json) =>
      _$AiMessageFromJson(json);
}
