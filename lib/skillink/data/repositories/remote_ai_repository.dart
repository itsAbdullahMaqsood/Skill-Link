import 'package:dio/dio.dart';
import 'package:skilllink/skillink/data/repositories/ai_repository.dart';
import 'package:skilllink/skillink/data/services/api_service.dart';
import 'package:skilllink/skillink/domain/models/ai_message.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/utils/result.dart';

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

  static Worker? _parseSuggestedWorker(Map<String, dynamic> m) {
    final id =
        m['_id']?.toString() ?? m['id']?.toString() ?? m['userId']?.toString();
    if (id == null || id.trim().isEmpty) return null;
    final name = m['fullName']?.toString() ??
        m['name']?.toString() ??
        'Technician';
    final skills = m['skillTypes'] ?? m['skills'];
    final skillTypes = skills is List
        ? skills.map((e) => e.toString()).toList()
        : const <String>[];
    return Worker(
      id: id.trim(),
      name: name.trim(),
      email: m['email']?.toString() ?? '',
      phone: m['phone']?.toString() ?? '',
      skillTypes: skillTypes,
      rating: (m['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (m['reviewCount'] as num?)?.toInt() ?? 0,
      verificationStatus: m['verificationStatus'] as bool? ?? false,
      avatarUrl: m['profilePic']?.toString() ?? m['avatarUrl']?.toString(),
      hourlyRate: (m['hourlyRate'] as num?)?.toDouble(),
      distanceKm: (m['distanceKm'] as num?)?.toDouble(),
      bio: m['bio']?.toString(),
    );
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

      Worker? recommended;
      final suggested = data['suggestedWorkers'];
      if (suggested is List) {
        for (final item in suggested) {
          final m = _asJsonMap(item);
          if (m == null) continue;
          recommended = _parseSuggestedWorker(m);
          if (recommended != null) break;
        }
      }

      final now = DateTime.now();
      final assistantMessage = AiMessage(
        id: assistantMessageId,
        role: AiMessageRole.ai,
        content: reply,
        createdAt: now,
        recommendedWorker: recommended,
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
