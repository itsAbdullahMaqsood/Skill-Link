import 'package:skilllink/skillink/domain/models/ai_message.dart';
import 'package:skilllink/skillink/utils/result.dart';

class AiChatAssistantReply {
  const AiChatAssistantReply({
    required this.userMessageId,
    required this.assistantMessage,
  });

  final String userMessageId;
  final AiMessage assistantMessage;
}

abstract class AiRepository {
  Future<Result<List<AiMessage>>> fetchHistory({
    int limit = 30,
    String? cursor,
  });

  Future<Result<AiChatAssistantReply>> sendMessage({
    required String sessionId,
    required String message,
    String? replyToMessageId,
    double? userLat,
    double? userLng,
  });
}
