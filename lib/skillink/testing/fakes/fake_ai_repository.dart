import 'package:skilllink/skillink/data/repositories/ai_repository.dart';
import 'package:skilllink/skillink/domain/models/ai_message.dart';
import 'package:skilllink/skillink/testing/models/sample_ai_responses.dart';
import 'package:skilllink/skillink/utils/result.dart';

class FakeAiRepository implements AiRepository {
  @override
  Future<Result<List<AiMessage>>> fetchHistory({
    int limit = 30,
    String? cursor,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const Success(<AiMessage>[]);
  }

  @override
  Future<Result<AiChatAssistantReply>> sendMessage({
    required String sessionId,
    required String message,
    String? replyToMessageId,
    double? userLat,
    double? userLng,
  }) async {
    await Future<void>.delayed(
      Duration(milliseconds: 400 + (message.length * 20).clamp(0, 400)),
    );

    final qa = SampleAiResponses.match(message);
    final now = DateTime.now();

    final aiMessage = AiMessage(
      id: 'ai_${now.millisecondsSinceEpoch}',
      role: AiMessageRole.ai,
      content: qa.response,
      createdAt: now,
      sources: const [],
      recommendedWorker: qa.recommendedWorker,
      suggestedTrade: qa.suggestedTrade,
    );

    return Success(
      AiChatAssistantReply(
        userMessageId: '',
        assistantMessage: aiMessage,
      ),
    );
  }

  String? lastReasonBlurb(String userMessage) {
    return SampleAiResponses.match(userMessage).reasonBlurb;
  }
}
