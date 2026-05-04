import 'package:dio/dio.dart';
import 'package:skilllink/skillink/data/mappers/worker_from_labour_api.dart';
import 'package:skilllink/skillink/data/repositories/ai_repository.dart';
import 'package:skilllink/skillink/data/services/api_service.dart';
import 'package:skilllink/skillink/domain/models/ai_message.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/utils/result.dart';

class _ScoredWorker {
  const _ScoredWorker(this.worker, this.score);
  final Worker worker;
  final double score;
}

class RemoteAiRepository implements AiRepository {
  RemoteAiRepository({required ApiService apiService}) : _api = apiService;

  final ApiService _api;

  static String _dioErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? 'Request failed';
  }

  static Map<String, dynamic>? _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  static AiMessageRole _roleFromApi(String? raw) {
    final r = raw?.toLowerCase().trim() ?? '';
    if (r == 'user') return AiMessageRole.user;
    return AiMessageRole.ai;
  }

  static AiMessage? _historyRowToMessage(Map<String, dynamic> m) {
    final id = m['id']?.toString().trim();
    final content = m['content']?.toString() ?? '';
    if (id == null || id.isEmpty || content.isEmpty) return null;
    final createdAt =
        DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now();
    return AiMessage(
      id: id,
      role: _roleFromApi(m['role']?.toString()),
      content: content,
      createdAt: createdAt,
    );
  }

  /// Maps an item from `/chatbot/chat`'s `suggestedWorkers[]` to a [Worker].
  ///
  /// The chatbot returns workers with already-resolved `serviceNames`
  /// (display labels like "Plumbing"), so we feed them into [Worker.skillTypes]
  /// alongside the standard labour-API fields handled by
  /// [workerFromLabourApiJson]. Returns `null` for malformed entries.
  static Worker? _parseSuggestedWorker(Map<String, dynamic> raw) {
    final id =
        raw['_id']?.toString() ?? raw['id']?.toString() ?? raw['userId']?.toString();
    if (id == null || id.trim().isEmpty) return null;

    final normalized = Map<String, dynamic>.from(raw);
    final serviceNames = raw['serviceNames'];
    if (serviceNames is List &&
        serviceNames.isNotEmpty &&
        normalized['services'] == null &&
        normalized['skillTypes'] == null) {
      normalized['services'] =
          serviceNames.map((e) => e.toString()).toList();
    }

    try {
      return workerFromLabourApiJson(normalized);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<List<AiMessage>>> fetchHistory({
    int limit = 30,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };
      final response = await _api.get<dynamic>('/chatbot/history', queryParameters: qp);
      final root = _asJsonMap(response.data);
      if (root == null) {
        return const Failure<List<AiMessage>>('Invalid history response');
      }
      final rawList = root['messages'];
      if (rawList is! List) {
        return const Success(<AiMessage>[]);
      }
      final out = <AiMessage>[];
      for (final item in rawList) {
        final m = _asJsonMap(item);
        if (m == null) continue;
        final msg = _historyRowToMessage(m);
        if (msg != null) out.add(msg);
      }
      out.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return Success(out);
    } on DioException catch (e) {
      return Failure<List<AiMessage>>(_dioErrorMessage(e), e);
    } catch (e) {
      return Failure<List<AiMessage>>('Failed to load chat history.', e is Exception ? e : Exception('$e'));
    }
  }

  @override
  Future<Result<AiChatAssistantReply>> sendMessage({
    required String sessionId,
    required String message,
    String? replyToMessageId,
    double? userLat,
    double? userLng,
  }) async {
    try {
      final response = await _api.post<dynamic>(
        '/chatbot/chat',
        data: <String, dynamic>{
          'message': message,
          'replyToMessageId': replyToMessageId,
        },
      );

      final data = _asJsonMap(response.data);
      if (data == null) {
        return const Failure<AiChatAssistantReply>('Invalid chat response');
      }

      final reply = data['reply']?.toString() ?? '';
      final userMessageId = data['userMessageId']?.toString().trim() ?? '';
      final assistantMessageId =
          data['assistantMessageId']?.toString().trim() ?? '';
      if (reply.isEmpty ||
          userMessageId.isEmpty ||
          assistantMessageId.isEmpty) {
        return const Failure<AiChatAssistantReply>('Incomplete chat response');
      }

      final recommendedWorkers = <Worker>[];
      final suggested = data['suggestedWorkers'];
      if (suggested is List) {
        final scored = <_ScoredWorker>[];
        for (final item in suggested) {
          final m = _asJsonMap(item);
          if (m == null) continue;
          final worker = _parseSuggestedWorker(m);
          if (worker == null) continue;
          final score = (m['matchScore'] as num?)?.toDouble() ?? 0;
          scored.add(_ScoredWorker(worker, score));
        }
        scored.sort((a, b) => b.score.compareTo(a.score));
        recommendedWorkers.addAll(scored.map((s) => s.worker));
      }

      final now = DateTime.now();
      final assistantMessage = AiMessage(
        id: assistantMessageId,
        role: AiMessageRole.ai,
        content: reply,
        createdAt: now,
        recommendedWorker:
            recommendedWorkers.isEmpty ? null : recommendedWorkers.first,
        recommendedWorkers: recommendedWorkers,
      );

      return Success(
        AiChatAssistantReply(
          userMessageId: userMessageId,
          assistantMessage: assistantMessage,
        ),
      );
    } on DioException catch (e) {
      return Failure<AiChatAssistantReply>(_dioErrorMessage(e), e);
    } catch (e) {
      return Failure<AiChatAssistantReply>(
        'Failed to get AI response. Please try again.',
        e is Exception ? e : Exception('$e'),
      );
    }
  }
}
