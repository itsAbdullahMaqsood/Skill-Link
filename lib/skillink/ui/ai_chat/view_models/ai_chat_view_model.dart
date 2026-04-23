import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';
import 'package:skilllink/skillink/domain/models/ai_message.dart';
import 'package:skilllink/skillink/testing/fakes/fake_ai_repository.dart';

/// When the user asks to show/suggest a worker, skip the chatbot backend and
/// surface a single worker from [WorkerRepository.searchWorkers] (GET /workers).
bool _messageTriggersLocalWorkerCard(String text) {
  final hasWorker = RegExp(r'\bworkers?\b', caseSensitive: false).hasMatch(text);
  if (!hasWorker) return false;
  final hasShow = RegExp(r'\bshow\b', caseSensitive: false).hasMatch(text);
  final hasSuggest =
      RegExp(r'\bsuggest\w*\b', caseSensitive: false).hasMatch(text);
  return hasShow || hasSuggest;
}

class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.isTyping = false,
    this.errorMessage,
    this.reasonBlurbs = const {},
    this.failedMessageId,
  });

  final List<AiMessage> messages;

  final bool isTyping;

  final String? errorMessage;

  final Map<String, String> reasonBlurbs;

  final String? failedMessageId;

  AiChatState copyWith({
    List<AiMessage>? messages,
    bool? isTyping,
    String? errorMessage,
    bool clearError = false,
    Map<String, String>? reasonBlurbs,
    String? failedMessageId,
    bool clearFailedMessageId = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      reasonBlurbs: reasonBlurbs ?? this.reasonBlurbs,
      failedMessageId: clearFailedMessageId
          ? null
          : (failedMessageId ?? this.failedMessageId),
    );
  }
}

class AiChatViewModel extends StateNotifier<AiChatState> {
  AiChatViewModel(this._ref) : super(const AiChatState());

  final Ref _ref;

  final String _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';

  bool _historyLoadRequested = false;

  Future<void> loadHistory() async {
    if (_historyLoadRequested) return;
    _historyLoadRequested = true;
    final repo = _ref.read(aiRepositoryProvider);
    final result = await repo.fetchHistory(limit: 30);
    if (!mounted) return;
    result.when(
      success: (list) {
        if (list.isEmpty) return;
        final existing = state.messages;
        if (existing.isEmpty) {
          state = state.copyWith(messages: list);
          return;
        }
        final have = existing.map((m) => m.id).toSet();
        final merged = [
          ...existing,
          ...list.where((m) => !have.contains(m.id)),
        ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        state = state.copyWith(messages: merged);
      },
      failure: (message, _) {
        debugPrint('[AiChat] history: $message');
      },
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();

    final pruned = state.failedMessageId == null
        ? state.messages
        : state.messages
            .where((m) => m.id != state.failedMessageId)
            .toList();

    final userMsg = AiMessage(
      id: 'user_${now.millisecondsSinceEpoch}',
      role: AiMessageRole.user,
      content: trimmed,
      createdAt: now,
    );
    state = state.copyWith(
      messages: [...pruned, userMsg],
      isTyping: true,
      clearError: true,
      clearFailedMessageId: true,
    );

    if (_messageTriggersLocalWorkerCard(trimmed)) {
      final workersResult = await _ref
          .read(workerRepositoryProvider)
          .searchWorkers(const WorkerSearchFilter());
      if (!mounted) return;
      workersResult.when(
        success: (workers) {
          final replyAt = DateTime.now();
          final picked = workers.isEmpty ? null : workers.first;
          final aiMessage = AiMessage(
            id: 'ai_local_${replyAt.millisecondsSinceEpoch}',
            role: AiMessageRole.ai,
            content: picked == null
                ? 'No workers are available to show right now.'
                : '',
            createdAt: replyAt,
            recommendedWorker: picked,
          );
          state = state.copyWith(
            messages: [...state.messages, aiMessage],
            isTyping: false,
            clearError: true,
            clearFailedMessageId: true,
          );
        },
        failure: (message, _) {
          state = state.copyWith(
            isTyping: false,
            errorMessage: message,
            failedMessageId: userMsg.id,
          );
        },
      );
      return;
    }

    final repo = _ref.read(aiRepositoryProvider);
    final result = await repo.sendMessage(
      sessionId: _sessionId,
      message: trimmed,
      replyToMessageId: null,
    );
    if (!mounted) return;

    result.when(
      success: (reply) {
        final aiMessage = reply.assistantMessage;
        final updatedBlurbs = Map<String, String>.from(state.reasonBlurbs);
        if (repo is FakeAiRepository) {
          final blurb = repo.lastReasonBlurb(trimmed);
          if (blurb != null) updatedBlurbs[aiMessage.id] = blurb;
        }

        var rows = List<AiMessage>.from(state.messages);
        if (reply.userMessageId.isNotEmpty) {
          final idx = rows.indexWhere((m) => m.id == userMsg.id);
          if (idx >= 0) {
            rows[idx] = rows[idx].copyWith(id: reply.userMessageId);
          }
        }

        state = state.copyWith(
          messages: [...rows, aiMessage],
          isTyping: false,
          reasonBlurbs: updatedBlurbs,
          clearError: true,
          clearFailedMessageId: true,
        );
      },
      failure: (message, _) {
        state = state.copyWith(
          isTyping: false,
          errorMessage: message,
          failedMessageId: userMsg.id,
        );
      },
    );
  }

  Future<void> retryFailedMessage() async {
    final failedId = state.failedMessageId;
    if (failedId == null) return;

    AiMessage? failedMsg;
    for (final m in state.messages) {
      if (m.id == failedId) {
        failedMsg = m;
        break;
      }
    }
    if (failedMsg == null) return;

    state = state.copyWith(
      messages: state.messages.where((m) => m.id != failedId).toList(),
      clearFailedMessageId: true,
    );
    await sendMessage(failedMsg.content);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final aiChatViewModelProvider =
    StateNotifierProvider.autoDispose<AiChatViewModel, AiChatState>(
  (ref) => AiChatViewModel(ref),
);
