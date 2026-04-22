import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/chat_message.dart';
import 'package:skilllink/skillink/domain/models/chat_summary.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/utils/chat_id.dart';

class ChatThreadState {
  const ChatThreadState({
    this.peer,
    this.messages = const [],
    this.bootstrapping = true,
    this.isSending = false,
    this.isLoadingEarlier = false,
    this.hasMoreEarlier = true,
    this.errorMessage,
  });

  final ChatSummary? peer;
  final List<ChatMessage> messages;
  final bool bootstrapping;
  final bool isSending;
  final bool isLoadingEarlier;
  final bool hasMoreEarlier;
  final String? errorMessage;

  ChatThreadState copyWith({
    ChatSummary? peer,
    List<ChatMessage>? messages,
    bool? bootstrapping,
    bool? isSending,
    bool? isLoadingEarlier,
    bool? hasMoreEarlier,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatThreadState(
      peer: peer ?? this.peer,
      messages: messages ?? this.messages,
      bootstrapping: bootstrapping ?? this.bootstrapping,
      isSending: isSending ?? this.isSending,
      isLoadingEarlier: isLoadingEarlier ?? this.isLoadingEarlier,
      hasMoreEarlier: hasMoreEarlier ?? this.hasMoreEarlier,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ChatThreadViewModel extends StateNotifier<ChatThreadState> {
  ChatThreadViewModel(this._ref, this._chatId) : super(const ChatThreadState()) {
    _ref.onCancel(() {
      _listenersDetached = true;
    });
    _bootstrap();
  }

  final Ref _ref;
  final String _chatId;
  StreamSubscription<List<ChatMessage>>? _messageSub;
  StreamSubscription<List<ChatSummary>>? _summarySub;

  bool _listenersDetached = false;

  String? get _myId => _ref.read(authViewModelProvider).user?.id;

  bool get _alive => !_listenersDetached;

  void _setStateIfAlive(ChatThreadState next) {
    if (!_alive) return;
    state = next;
  }

  String? _resolvePeerId() {
    final me = _myId;
    if (me == null) return null;
    if (_chatId.startsWith('c_')) {
      return peerIdFor(_chatId, me);
    }
    return state.peer?.peerId ??
        _ref.read(chatRepositoryProvider).cachedPeerIdForChat(_chatId, me);
  }

  void _bootstrap() {
    final me = _myId;
    if (me == null) {
      _setStateIfAlive(
        state.copyWith(
          bootstrapping: false,
          errorMessage: 'Not signed in.',
        ),
      );
      return;
    }
    final repo = _ref.read(chatRepositoryProvider);

    var firstEmit = true;
    _messageSub = repo
        .watchMessages(_chatId, limit: AppConstants.chatMessagePageSize)
        .listen((msgs) {
      if (!_alive) return;
      final hasMore = firstEmit
          ? msgs.length >= AppConstants.chatMessagePageSize
          : state.hasMoreEarlier;
      firstEmit = false;
      _setStateIfAlive(
        state.copyWith(
          messages: msgs,
          bootstrapping: false,
          hasMoreEarlier: hasMore,
        ),
      );
    }, onError: (Object e) {
      if (!_alive) return;
      _setStateIfAlive(
        state.copyWith(
          bootstrapping: false,
          errorMessage: 'Could not load messages.',
        ),
      );
    });

    _summarySub = repo.watchUserChats(me).listen((summaries) {
      if (!_alive) return;
      ChatSummary? match;
      for (final s in summaries) {
        if (s.chatId == _chatId) {
          match = s;
          break;
        }
      }
      if (match != null) {
        _setStateIfAlive(state.copyWith(peer: match));
      }
    });

    unawaited(repo.markRead(chatId: _chatId, viewerId: me));
  }

  Future<void> markRead() async {
    final me = _myId;
    if (me == null || !_alive) return;
    await _ref
        .read(chatRepositoryProvider)
        .markRead(chatId: _chatId, viewerId: me);
  }

  Future<void> loadEarlier() async {
    if (state.isLoadingEarlier || !state.hasMoreEarlier) return;
    if (state.messages.isEmpty) return;

    _setStateIfAlive(state.copyWith(isLoadingEarlier: true, clearError: true));
    if (!_alive) return;
    final oldest = state.messages.first.sentAt;
    final res = await _ref.read(chatRepositoryProvider).loadMessagesBefore(
          chatId: _chatId,
          before: oldest,
          limit: AppConstants.chatMessagePageSize,
        );
    if (!_alive) return;
    res.when(
      success: (older) {
        if (!_alive) return;
        final seen = state.messages.map((m) => m.messageId).toSet();
        final fresh = older.where((m) => !seen.contains(m.messageId)).toList();
        final combined = [...fresh, ...state.messages];
        _setStateIfAlive(
          state.copyWith(
            messages: combined,
            isLoadingEarlier: false,
            hasMoreEarlier: older.length >= AppConstants.chatMessagePageSize,
          ),
        );
      },
      failure: (msg, _) {
        if (!_alive) return;
        _setStateIfAlive(
          state.copyWith(isLoadingEarlier: false, errorMessage: msg),
        );
      },
    );
  }

  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;
    final me = _myId;
    final peerId = _resolvePeerId();
    if (me == null || peerId == null) return;

    _setStateIfAlive(state.copyWith(isSending: true, clearError: true));
    if (!_alive) return;
    final res = await _ref.read(chatRepositoryProvider).sendText(
          chatId: _chatId,
          senderId: me,
          peerId: peerId,
          text: trimmed,
        );
    if (!_alive) return;
    _setStateIfAlive(
      state.copyWith(
        isSending: false,
        errorMessage: res.errorOrNull,
      ),
    );
  }

  Future<void> sendImage(File image) async {
    if (state.isSending) return;
    final me = _myId;
    final peerId = _resolvePeerId();
    if (me == null || peerId == null) return;

    _setStateIfAlive(state.copyWith(isSending: true, clearError: true));
    if (!_alive) return;
    final res = await _ref.read(chatRepositoryProvider).sendImage(
          chatId: _chatId,
          senderId: me,
          peerId: peerId,
          imageFile: image,
        );
    if (!_alive) return;
    _setStateIfAlive(
      state.copyWith(
        isSending: false,
        errorMessage: res.errorOrNull,
      ),
    );
  }

  Future<void> sendAudio(File audio, {required int durationMs}) async {
    if (state.isSending) return;
    final me = _myId;
    final peerId = _resolvePeerId();
    if (me == null || peerId == null) return;

    _setStateIfAlive(state.copyWith(isSending: true, clearError: true));
    if (!_alive) return;
    final res = await _ref.read(chatRepositoryProvider).sendAudio(
          chatId: _chatId,
          senderId: me,
          peerId: peerId,
          audioFile: audio,
          durationMs: durationMs,
        );
    if (!_alive) return;
    _setStateIfAlive(
      state.copyWith(
        isSending: false,
        errorMessage: res.errorOrNull,
      ),
    );
  }

  void clearError() =>
      _setStateIfAlive(state.copyWith(clearError: true));

  @override
  void dispose() {
    _messageSub?.cancel();
    _summarySub?.cancel();
    super.dispose();
  }
}

final chatThreadViewModelProvider = StateNotifierProvider.autoDispose
    .family<ChatThreadViewModel, ChatThreadState, String>(
  (ref, chatId) => ChatThreadViewModel(ref, chatId),
);
