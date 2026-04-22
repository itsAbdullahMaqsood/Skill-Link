import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:skilllink/models/chat_models.dart';
import 'package:skilllink/services/api_service.dart';
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/services/skillink_api_service.dart';
import 'package:skilllink/skillink/config/app_constants.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  final StreamController<List<ChatConversationPreview>> _conversationsController =
      StreamController<List<ChatConversationPreview>>.broadcast();
  final StreamController<ChatConnectionStatus> _connectionController =
      StreamController<ChatConnectionStatus>.broadcast();

  final Map<String, ChatConversationPreview> _conversationsById = {};
  final Map<String, List<ChatMessageModel>> _messagesByConversation = {};
  final Map<String, StreamController<List<ChatMessageModel>>>
      _messagesControllers = {};
  final Map<String, StreamController<bool>> _typingControllers = {};
  final Map<String, dynamic> _ticketIdByConversation = {};
  final Map<String, String> _roomIdByTicketKey = {};
  final Map<String, String> _otherUserIdByRoom = {};
  final Set<String> _joinedRoomIds = {};
  final Map<String, Completer<void>> _joinRoomCompleters = {};
  final Map<String, Future<void>> _historyFetches = {};
  String? _pendingJoinRoomId;
  Completer<void>? _registerAckCompleter;

  socket_io.Socket? _socket;
  bool _socketListenersAttached = false;
  bool _socketRegistered = false;
  String _lastSocketToken = '';
  String _lastChatBackendKey = '';
  String _lastTicketMapUserId = '';

  bool _initialized = false;
  String _currentUserId = 'me';
  ChatConnectionStatus _connectionStatus = ChatConnectionStatus.disconnected;

  String get currentUserId => _currentUserId;
  ChatConnectionStatus get status => _connectionStatus;

  Future<void> initialize() async {
    final user = await _authService.getCurrentUser();
    final nextId = user?.id.isNotEmpty == true ? user!.id : 'me';

    if (_initialized) {
      if (nextId != _currentUserId) {
        debugPrint('[Chat] user switched $_currentUserId -> $nextId, resetting state');
        await _resetForUserSwitch();
        _currentUserId = nextId;
        await _loadTicketMapForUser(_currentUserId);
        await _loadRoomPeersFromPrefs(_currentUserId);
      }
      unawaited(_refreshInboxFromServer());
      await _ensureSocketConnected();
      _emitConversations();
      return;
    }

    _seedLocalState();
    _currentUserId = nextId;
    await _loadTicketMapForUser(_currentUserId);
    await _loadRoomPeersFromPrefs(_currentUserId);
    _initialized = true;

    await _refreshInboxFromServer();
    await _ensureSocketConnected();
    _emitConversations();
  }

  Stream<List<ChatConversationPreview>> watchConversations() async* {
    final initial = _conversationsById.values.toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    yield initial;
    yield* _conversationsController.stream;
  }

  Stream<List<ChatMessageModel>> watchMessages(String conversationId) async* {
    _messagesControllers.putIfAbsent(
      conversationId,
      () => StreamController<List<ChatMessageModel>>.broadcast(),
    );
    yield List<ChatMessageModel>.from(_messages(conversationId));
    unawaited(fetchRoomHistory(conversationId));
    unawaited(_ensureRoomJoined(roomId: conversationId).catchError((e, st) {
      debugPrint('[Chat] watchMessages join failed room=$conversationId: $e');
    }));
    yield* _messagesControllers[conversationId]!.stream;
  }

  Future<void> fetchRoomHistory(String roomId) {
    return _historyFetches.putIfAbsent(
      roomId,
      () => _fetchMessagesForRoom(roomId).whenComplete(
        () => _historyFetches.remove(roomId),
      ),
    );
  }

  Stream<bool> watchTyping(String conversationId) async* {
    final controller = _typingControllers.putIfAbsent(
      conversationId,
      () => StreamController<bool>.broadcast(),
    );
    yield false;
    yield* controller.stream;
  }

  Stream<ChatConnectionStatus> watchConnection() => _connectionController.stream;

  String? getBackendTicketId(String conversationId) {
    final ticketId = _ticketIdByConversation[conversationId];
    return ticketId?.toString();
  }

  /// Other participant for a server-issued room id (SkillChain / SkillLink socket API).
  /// Deterministic `c_*` chat ids from tests do not use this path.
  String? getPeerUserIdForRoom(String roomId) {
    final r = roomId.trim();
    if (r.isEmpty) return null;
    final fromMap = _otherUserIdByRoom[r]?.trim();
    if (fromMap != null && fromMap.isNotEmpty) return fromMap;
    final fromPreview = _conversationsById[r]?.participantId.trim();
    if (fromPreview != null && fromPreview.isNotEmpty) return fromPreview;
    return null;
  }

  Future<void> refreshInbox() => _refreshInboxFromServer();

  String? _activeConversationId;
  void setActiveConversation(String? conversationId) {
    _activeConversationId = conversationId;
  }

  Future<String> openOrCreateConversation({
    required String participantId,
    required String participantName,
    required String participantAvatar,
    required bool participantOnline,
  }) async {
    final other = participantId.trim();
    if (other.isEmpty || other == _currentUserId) {
      throw StateError('Invalid chat participant');
    }

    for (final c in _conversationsById.values) {
      if (c.participantId == other) return c.id;
    }

    final Response response;
    try {
      response = await _chatPost(
        '/messages/rooms',
        data: <String, dynamic>{'userId': other},
      );
    } on DioException catch (e) {
      final msg = _coerceJsonMap(e.response?.data)?['message']?.toString();
      throw StateError(msg ?? e.message ?? 'Could not open chat room');
    }
    final map = _unwrapEnvelope(_coerceJsonMap(response.data));
    final roomId = _extractRoomId(map);
    if (roomId.isEmpty) {
      debugPrint(
        '[Chat] POST /messages/rooms response shape unexpected: '
        'keys=${map?.keys.toList() ?? const []}',
      );
      throw StateError('Missing roomId from POST /messages/rooms');
    }

    _conversationsById[roomId] = ChatConversationPreview(
      id: roomId,
      participantId: other,
      participantName: participantName,
      participantAvatar: participantAvatar,
      participantOnline: participantOnline,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isMyLastMessage: false,
    );
    _messagesByConversation.putIfAbsent(roomId, () => <ChatMessageModel>[]);
    _otherUserIdByRoom[roomId] = other;
    _emitConversations();
    await _persistRoomIndex();
    return roomId;
  }

  void ensureConversationShell({
    required String roomId,
    required String otherUserId,
    required String otherName,
    required String otherAvatar,
    required bool participantOnline,
  }) {
    final oid = otherUserId.trim();
    if (roomId.trim().isEmpty || oid.isEmpty) return;
    _otherUserIdByRoom[roomId] = oid;
    if (_conversationsById.containsKey(roomId)) {
      final cur = _conversationsById[roomId]!;
      if (cur.participantId != oid) {
        _conversationsById[roomId] = cur.copyWith(
          participantId: oid,
          participantName: otherName.trim().isEmpty ? cur.participantName : otherName.trim(),
          participantAvatar: otherAvatar.trim().isEmpty ? cur.participantAvatar : otherAvatar,
        );
        _emitConversations();
      }
      return;
    }
    _conversationsById[roomId] = ChatConversationPreview(
      id: roomId,
      participantId: oid,
      participantName: otherName.trim().isEmpty ? 'User' : otherName.trim(),
      participantAvatar: otherAvatar,
      participantOnline: participantOnline,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isMyLastMessage: false,
    );
    _messagesByConversation.putIfAbsent(roomId, () => <ChatMessageModel>[]);
    _emitConversations();
  }

  Future<void> markConversationAsRead(String conversationId) async {
    final existing = _conversationsById[conversationId];
    if (existing == null) return;
    _conversationsById[conversationId] = existing.copyWith(unreadCount: 0);
    _emitConversations();
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    String? recipientUserId,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final preview = _conversationsById[conversationId];
    final fromPreview = preview?.participantId.trim() ?? '';
    final toUserId = fromPreview.isNotEmpty
        ? fromPreview
        : (recipientUserId ?? _otherUserIdByRoom[conversationId] ?? '').trim();
    if (toUserId.isEmpty) {
      debugPrint('[Chat] send skipped: missing toUserId for room=$conversationId');
      return;
    }
    _otherUserIdByRoom[conversationId] = toUserId;

    final localId = 'local_${DateTime.now().microsecondsSinceEpoch}';
    final pending = ChatMessageModel(
      id: localId,
      conversationId: conversationId,
      senderId: _currentUserId,
      text: trimmed,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.sending,
    );
    _appendMessage(conversationId, pending);
    _updateConversationFromMessage(
      conversationId: conversationId,
      message: pending,
      sentByMe: true,
    );

    try {
      await _ensureSocketConnected();
      try {
        await _ensureRoomJoined(
          roomId: conversationId,
          timeout: const Duration(seconds: 4),
        );
      } catch (e) {
        debugPrint('[Chat] join not acked, sending anyway: $e');
      }
      final sock = _socket;
      if (sock == null || !sock.connected) {
        throw StateError('Chat socket not connected');
      }
      sock.emit('privateMessage', <String, dynamic>{
        'roomId': conversationId,
        'toUserId': toUserId,
        'message': trimmed,
        'type': 'text',
      });
      _updateMessageStatus(
        conversationId: conversationId,
        messageId: localId,
        status: ChatMessageStatus.sent,
      );
    } catch (e, st) {
      debugPrint('[Chat] privateMessage emit failed: $e\n$st');
      _updateMessageStatus(
        conversationId: conversationId,
        messageId: localId,
        status: ChatMessageStatus.failed,
      );
    }
  }

  void setTyping({
    required String conversationId,
    required bool isTyping,
  }) {}

  Future<void> dispose() async {
    await _disconnectSocket();
    for (final controller in _messagesControllers.values) {
      await controller.close();
    }
    for (final controller in _typingControllers.values) {
      await controller.close();
    }
    await _conversationsController.close();
    await _connectionController.close();
  }


  Future<void> _ensureSocketConnected() async {
    if (_currentUserId.isEmpty || _currentUserId == 'me') {
      _setConnection(ChatConnectionStatus.disconnected);
      return;
    }
    final token = (await _authService.getAccessToken())?.trim() ?? '';
    if (token.isEmpty) {
      await _disconnectSocket();
      _setConnection(ChatConnectionStatus.disconnected);
      return;
    }
    final backendKey = await _labourChat() ? 'labour' : 'digital';
    if (_socket != null &&
        _lastSocketToken == token &&
        _lastChatBackendKey == backendKey &&
        (_socket!.connected == true || _connectionStatus == ChatConnectionStatus.connecting)) {
      return;
    }
    await _disconnectSocket();
    _lastSocketToken = token;
    _lastChatBackendKey = backendKey;
    _setConnection(ChatConnectionStatus.connecting);

    final uri = await _chatSocketBaseUrl();
    final opts = socket_io.OptionBuilder()
        .setTransports(<String>['websocket', 'polling'])
        .disableAutoConnect()
        .enableForceNew()
        .enableReconnection()
        .setReconnectionAttempts(8)
        .setReconnectionDelay(1000)
        .setExtraHeaders(<String, String>{'Authorization': 'Bearer $token'})
        .setQuery(<String, dynamic>{'token': token})
        .setAuth(<String, dynamic>{'token': token, 'userId': _currentUserId})
        .build();

    final socket = socket_io.io(uri, opts);
    _socket = socket;
    _attachSocketListeners(socket);
    socket.connect();
  }

  void _attachSocketListeners(socket_io.Socket socket) {
    if (_socketListenersAttached) return;
    _socketListenersAttached = true;

    socket.onConnect((_) {
      _failPendingJoins('Socket reconnecting');
      final oldReg = _registerAckCompleter;
      if (oldReg != null && !oldReg.isCompleted) {
        oldReg.completeError(StateError('Socket reconnecting'));
      }
      _registerAckCompleter = Completer<void>();
      _socketRegistered = false;
      _joinedRoomIds.clear();
      _setConnection(ChatConnectionStatus.connected);
      debugPrint('[Chat] socket connected, emitting register');
      socket.emit('register', <String, dynamic>{'userId': _currentUserId});
    });

    socket.onDisconnect((_) {
      debugPrint('[Chat] socket disconnected');
      _socketRegistered = false;
      _joinedRoomIds.clear();
      _failPendingJoins('Socket disconnected');
      if (_registerAckCompleter != null && !_registerAckCompleter!.isCompleted) {
        _registerAckCompleter!.completeError(StateError('Socket disconnected'));
      }
      _registerAckCompleter = null;
      _setConnection(ChatConnectionStatus.disconnected);
    });

    socket.onConnectError((dynamic e) {
      debugPrint('[Chat] socket connect_error: $e');
      _setConnection(ChatConnectionStatus.disconnected);
    });

    socket.on('user join', _onSocketUserJoin);
    socket.on('userJoin', _onSocketUserJoin);
    socket.on('registered', _onSocketUserJoin);
    socket.on('joinedRoom', _onJoinedRoom);
    socket.on('privateMessage', _onPrivateMessage);
    socket.on('newMessage', _onPrivateMessage);
    socket.on('message', _onPrivateMessage);
    socket.on('error', _onSocketServerError);
  }

  void _onSocketUserJoin(dynamic _) {
    _socketRegistered = true;
    final c = _registerAckCompleter;
    if (c != null && !c.isCompleted) {
      c.complete();
    }
    debugPrint('[Chat] socket registered');
    for (final e in _otherUserIdByRoom.entries) {
      if (_joinedRoomIds.contains(e.key)) continue;
      _emitJoinRoom(e.key, e.value);
    }
  }

  void _emitJoinRoom(String roomId, String otherUserId) {
    final sock = _socket;
    if (sock == null || !sock.connected) return;
    _pendingJoinRoomId = roomId;
    debugPrint('[Chat] emit joinRoom roomId=$roomId other=$otherUserId');
    sock.emit('joinRoom', <String, dynamic>{
      'roomId': roomId,
      'userId': otherUserId,
    });
  }

  void _onJoinedRoom(dynamic raw) {
    final m = _coerceJsonMap(raw);
    if (m == null) return;
    final roomId = m['roomId']?.toString().trim();
    final ticketId = m['ticketId'];
    if (roomId == null || roomId.isEmpty) return;

    _joinedRoomIds.add(roomId);
    if (ticketId != null) {
      _setTicketMapping(roomId, ticketId);
      _roomIdByTicketKey[_ticketKey(ticketId)] = roomId;
    }
    debugPrint('[Chat] joinedRoom roomId=$roomId ticketId=$ticketId');
    if (_pendingJoinRoomId == roomId) _pendingJoinRoomId = null;
    _joinRoomCompleters.remove(roomId)?.complete();
  }

  void _onPrivateMessage(dynamic raw) {
    var m = _coerceJsonMap(raw);
    if (m == null) return;
    final inner = _coerceJsonMap(m['data']) ?? _coerceJsonMap(m['payload']);
    if (inner != null && (inner['message'] != null || inner['userId'] != null)) {
      m = inner;
    }

    final from = _extractSenderId(m);
    final text = (m['message'] ?? m['text'] ?? m['content'] ?? '').toString();
    if (text.trim().isEmpty) return;

    final ticketRaw = m['ticketId'];
    var roomId = _extractRoomId(m);
    if (roomId.isEmpty) {
      final roomVal = m['room'];
      if (roomVal is String) roomId = roomVal.trim();
    }
    if (roomId.isEmpty) {
      roomId = _roomIdByTicketKey[_ticketKey(ticketRaw)] ?? '';
    }
    if (roomId.isEmpty) {
      debugPrint('[Chat] privateMessage: could not resolve room (keys=${m.keys.toList()})');
      return;
    }

    final serverId = (m['_id'] ?? m['id'] ?? '').toString();
    final createdAt =
        DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now();
    final id = serverId.isNotEmpty
        ? serverId
        : 'pm_${from}_${createdAt.millisecondsSinceEpoch}_${text.hashCode}';

    final msg = ChatMessageModel(
      id: id,
      conversationId: roomId,
      senderId: from,
      text: text,
      timestamp: createdAt,
      status: from == _currentUserId
          ? ChatMessageStatus.sent
          : ChatMessageStatus.delivered,
    );

    if (from == _currentUserId) {
      _stripOptimisticEcho(roomId, text: text, createdAt: createdAt);
    }
    _dedupeAndAppend(roomId, msg);

    final shellMissing = !_conversationsById.containsKey(roomId);
    if (shellMissing) {
      final otherId = from == _currentUserId
          ? (_otherUserIdByRoom[roomId] ?? '')
          : from;
      if (otherId.isNotEmpty) {
        _otherUserIdByRoom[roomId] = otherId;
        ensureConversationShell(
          roomId: roomId,
          otherUserId: otherId,
          otherName: 'User',
          otherAvatar: '',
          participantOnline: false,
        );
      } else {
        unawaited(
          _refreshInboxFromServer().then((_) {
            if (!_conversationsById.containsKey(roomId)) return;
            final viewing = _activeConversationId == roomId;
            _updateConversationFromMessage(
              conversationId: roomId,
              message: msg,
              sentByMe: from == _currentUserId,
              incrementUnread: from != _currentUserId && !viewing,
            );
          }),
        );
        return;
      }
      unawaited(_refreshInboxFromServer());
    }

    final viewing = _activeConversationId == roomId;
    _updateConversationFromMessage(
      conversationId: roomId,
      message: msg,
      sentByMe: from == _currentUserId,
      incrementUnread: from != _currentUserId && !viewing,
    );
  }

  void _stripOptimisticEcho(
    String roomId, {
    required String text,
    required DateTime createdAt,
  }) {
    final list = _messages(roomId);
    list.removeWhere(
      (m) =>
          m.id.startsWith('local_') &&
          m.senderId == _currentUserId &&
          m.text == text &&
          m.status != ChatMessageStatus.failed &&
          (m.timestamp.difference(createdAt).inSeconds).abs() <= 30,
    );
    _emitMessages(roomId);
  }

  void _dedupeAndAppend(String roomId, ChatMessageModel msg) {
    final list = _messages(roomId);
    final isServerId = !msg.id.startsWith('local_') && !msg.id.startsWith('pm_');
    if (isServerId && list.any((x) => x.id == msg.id)) return;
    if (!isServerId) {
      final dup = list.any(
        (x) =>
            x.senderId == msg.senderId &&
            x.text == msg.text &&
            (x.timestamp.difference(msg.timestamp).inMilliseconds).abs() < 3000,
      );
      if (dup) return;
    }
    _appendMessage(roomId, msg);
  }

  void _onSocketServerError(dynamic raw) {
    final m = _coerceJsonMap(raw);
    final ev = m?['event']?.toString();
    final msg = m?['message']?.toString() ?? '';
    debugPrint('[Chat] socket error event: $ev $msg');
    if (ev == 'joinRoom') {
      final rid = _pendingJoinRoomId;
      if (rid != null) {
        _pendingJoinRoomId = null;
        final c = _joinRoomCompleters.remove(rid);
        if (c != null && !c.isCompleted) {
          c.completeError(Exception(msg.isEmpty ? 'joinRoom failed' : msg));
        }
      }
    }
  }

  Future<void> _ensureRoomJoined({
    required String roomId,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    await _ensureSocketConnected();
    final sock = _socket;
    if (sock == null) throw StateError('Socket unavailable');
    if (!sock.connected) {
      throw StateError('Socket not connected');
    }
    await _awaitRegisterAck();
    if (_joinedRoomIds.contains(roomId)) return;

    final existingWait = _joinRoomCompleters[roomId];
    if (existingWait != null) {
      await existingWait.future.timeout(timeout);
      return;
    }

    final other = _otherUserIdByRoom[roomId] ??
        _conversationsById[roomId]?.participantId ??
        '';
    if (other.isEmpty) {
      throw StateError('Missing other participant for joinRoom');
    }

    final c = Completer<void>();
    _joinRoomCompleters[roomId] = c;
    _emitJoinRoom(roomId, other);

    try {
      await c.future.timeout(timeout);
    } on TimeoutException {
      _joinRoomCompleters.remove(roomId);
      rethrow;
    }
  }

  void _failPendingJoins(String reason) {
    final copy = Map<String, Completer<void>>.from(_joinRoomCompleters);
    _joinRoomCompleters.clear();
    for (final c in copy.values) {
      if (!c.isCompleted) c.completeError(Exception(reason));
    }
  }

  Future<void> _awaitRegisterAck() async {
    if (_socketRegistered) return;
    final c = _registerAckCompleter;
    if (c == null) {
      for (var i = 0; i < 40 && !_socketRegistered; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }
      if (!_socketRegistered) {
        throw StateError('Chat register (user join) not received');
      }
      return;
    }
    await c.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () => throw TimeoutException('Chat register timed out'),
    );
  }

  Future<void> _resetForUserSwitch() async {
    await _disconnectSocket();
    _conversationsById.clear();
    _messagesByConversation.clear();
    _otherUserIdByRoom.clear();
    _ticketIdByConversation.clear();
    _roomIdByTicketKey.clear();
    _lastTicketMapUserId = '';
    for (final c in _messagesControllers.values) {
      if (!c.isClosed) c.add(const <ChatMessageModel>[]);
    }
    _emitConversations();
  }

  Future<void> _disconnectSocket() async {
    _failPendingJoins('Socket reset');
    if (_registerAckCompleter != null && !_registerAckCompleter!.isCompleted) {
      _registerAckCompleter!.completeError(StateError('Socket reset'));
    }
    _registerAckCompleter = null;
    final s = _socket;
    _socket = null;
    _socketListenersAttached = false;
    _socketRegistered = false;
    _joinedRoomIds.clear();
    _lastSocketToken = '';
    _lastChatBackendKey = '';
    if (s != null) {
      try {
        s.dispose();
      } catch (_) {}
    }
  }

  String _ticketKey(dynamic ticket) =>
      ticket == null ? '' : ticket.toString().trim();

  String _extractSenderId(Map<String, dynamic> m) {
    for (final key in const ['fromUserId', 'senderId', 'from', 'userId', 'sender']) {
      final v = m[key];
      if (v == null) continue;
      final asMap = _coerceJsonMap(v);
      if (asMap != null) {
        final id = (asMap['_id'] ?? asMap['id'] ?? '').toString();
        if (id.trim().isNotEmpty) return id;
        continue;
      }
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return '';
  }


  Future<bool> _labourChat() => _authService.isLabourBackend();

  Future<Response<dynamic>> _chatGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (await _labourChat()) {
      return SkillinkApiService.instance.get(path, queryParameters: queryParameters);
    }
    return _apiService.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> _chatPost(String path, {dynamic data}) async {
    if (await _labourChat()) {
      return SkillinkApiService.instance.post(path, data: data);
    }
    return _apiService.post(path, data: data);
  }

  Future<String> _chatSocketBaseUrl() async {
    if (await _labourChat()) {
      return AppConstants.apiBaseUrl.trim();
    }
    return ApiService.baseUrl.trim();
  }

  Future<void> _fetchMessagesForRoom(String roomId) async {
    try {
      final response =
          await _chatGet('/messages/conversation/$roomId', queryParameters: {
        'limit': 50,
        'offset': 0,
      });
      final data = _conversationFetchMap(response.data);
      if (data == null) return;

      final rawMessages = data['messages'];
      if (rawMessages is! List) return;

      final mapped = rawMessages
          .map((e) => _mapApiMessage(roomId, e))
          .where((e) => e != null)
          .cast<ChatMessageModel>()
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final merged = _mergeHistoryWithPendingLocals(roomId, mapped);
      _messagesByConversation[roomId] = merged;
      _emitMessages(roomId);
      if (merged.isNotEmpty) {
        final last = merged.last;
        _updateConversationFromMessage(
          conversationId: roomId,
          message: last,
          sentByMe: last.isFrom(_currentUserId),
        );
      }
    } on DioException catch (e) {
      debugPrint('[Chat] GET conversation failed room=$roomId: $e');
    } catch (e) {
      debugPrint('[Chat] fetch parse error room=$roomId: $e');
    }
  }

  Future<void> _refreshInboxFromServer() async {
    if (_currentUserId == 'me') return;
    try {
      final response = await _chatGet(
        '/messages/my-chats',
        queryParameters: {'limit': 30, 'offset': 0},
      );
      final root = _coerceJsonMap(response.data);
      if (root == null) return;
      final list = root['conversations'];
      if (list is! List) return;

      for (final item in list) {
        final m = _coerceJsonMap(item);
        if (m == null) continue;
        final roomId = _extractRoomId(m);
        if (roomId.isEmpty) continue;

        final lm = _coerceJsonMap(m['lastMessage']);
        final lastText = lm?['message']?.toString() ?? '';
        final lastTime =
            DateTime.tryParse(lm?['createdAt']?.toString() ?? '') ??
                DateTime.now();
        final senderLm = _coerceJsonMap(lm?['sender']);
        final lastSenderId =
            senderLm?['_id']?.toString() ?? senderLm?['id']?.toString() ?? '';
        final isMyLast =
            lastSenderId.isNotEmpty && lastSenderId == _currentUserId;

        String otherId = '';
        String otherName = 'User';
        String otherPic = '';
        final participants = m['participants'];
        if (participants is List) {
          for (final p in participants) {
            final u = _coerceJsonMap(p);
            final id = u?['_id']?.toString() ?? u?['id']?.toString() ?? '';
            if (id.isNotEmpty && id != _currentUserId) {
              otherId = id;
              otherName = u?['fullName']?.toString() ?? 'User';
              otherPic = u?['profilePic']?.toString() ?? '';
              break;
            }
          }
        }
        if (otherId.isEmpty) continue;

        _otherUserIdByRoom[roomId] = otherId;
        final prev = _conversationsById[roomId];
        _conversationsById[roomId] = ChatConversationPreview(
          id: roomId,
          participantId: otherId,
          participantName: otherName,
          participantAvatar: otherPic,
          lastMessage: lastText.isNotEmpty ? lastText : (prev?.lastMessage ?? ''),
          lastMessageTime: lastTime,
          participantOnline: prev?.participantOnline ?? false,
          unreadCount: prev?.unreadCount ?? 0,
          isMyLastMessage: isMyLast,
        );
        _messagesByConversation.putIfAbsent(roomId, () => <ChatMessageModel>[]);
      }
      _emitConversations();
      await _persistRoomIndex();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint(
          '[Chat] GET /messages/my-chats not found — adjust path if your API differs',
        );
      } else {
        debugPrint('[Chat] inbox refresh failed: $e');
      }
    }
  }

  ChatMessageModel? _mapApiMessage(String roomId, dynamic raw) {
    final row = _coerceJsonMap(raw);
    if (row == null) return null;

    final id = (row['_id'] ?? row['id'] ?? '').toString();
    if (id.trim().isEmpty) return null;

    final user = row['userId'];
    String senderId = '';
    final userMap = _coerceJsonMap(user);
    if (userMap != null) {
      senderId = (userMap['_id'] ?? userMap['id'] ?? '').toString();
    } else if (user != null) {
      senderId = user.toString();
    }
    if (senderId.trim().isEmpty) senderId = 'unknown';

    final text = (row['message'] ?? '').toString();
    final createdAt =
        DateTime.tryParse((row['createdAt'] ?? '').toString()) ??
            DateTime.now();

    return ChatMessageModel(
      id: id,
      conversationId: roomId,
      senderId: senderId,
      text: text,
      timestamp: createdAt,
      status: senderId == _currentUserId
          ? ChatMessageStatus.sent
          : ChatMessageStatus.delivered,
    );
  }

  Map<String, dynamic>? _conversationFetchMap(dynamic data) {
    final top = _coerceJsonMap(data);
    if (top == null) return null;
    if (top['messages'] is List) return top;
    for (final k in const ['data', 'result', 'payload']) {
      final inner = _coerceJsonMap(top[k]);
      if (inner != null && inner['messages'] is List) return inner;
    }
    return top;
  }


  void _setConnection(ChatConnectionStatus s) {
    _connectionStatus = s;
    _connectionController.add(s);
  }

  void _seedLocalState() {}

  Map<String, dynamic>? _coerceJsonMap(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return _coerceJsonMap(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  List<ChatMessageModel> _mergeHistoryWithPendingLocals(
    String roomId,
    List<ChatMessageModel> fromServer,
  ) {
    final prior = _messages(roomId);
    final pending = prior
        .where(
          (m) =>
              m.id.startsWith('local_') &&
              m.status != ChatMessageStatus.failed,
        )
        .where(
          (local) => !fromServer.any(
            (s) =>
                s.senderId == local.senderId &&
                s.text == local.text &&
                (s.timestamp.difference(local.timestamp).inSeconds).abs() <= 45,
          ),
        )
        .toList();
    if (pending.isEmpty) return fromServer;
    final out = [...fromServer, ...pending]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return out;
  }

  Future<void> _loadRoomPeersFromPrefs(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('skillchain_chat_room_peers_$userId');
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      final map = _coerceJsonMap(decoded);
      if (map == null) return;
      map.forEach((k, v) {
        if (v is String && v.trim().isNotEmpty) {
          _otherUserIdByRoom[k] = v.trim();
        }
      });
    } catch (e) {
      debugPrint('[Chat] load room peers failed: $e');
    }
  }

  Map<String, dynamic>? _unwrapEnvelope(Map<String, dynamic>? m) {
    if (m == null) return null;
    for (final k in const ['data', 'result', 'payload']) {
      final inner = _coerceJsonMap(m[k]);
      if (inner != null && inner.keys.any(_isRoomOrMessageKey)) return inner;
    }
    return m;
  }

  static bool _isRoomOrMessageKey(String k) => const {
        'roomId',
        '_id',
        'id',
        'chatId',
        'room',
        'message',
        'text',
        'createdAt',
      }.contains(k);

  String _extractRoomId(Map<String, dynamic>? m) {
    if (m == null) return '';
    for (final k in const ['roomId', 'chatId', '_id', 'id']) {
      final v = m[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    final nested = _coerceJsonMap(m['room']);
    if (nested != null) {
      for (final k in const ['roomId', 'chatId', '_id', 'id']) {
        final v = nested[k];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
    }
    return '';
  }

  void _updateMessageStatus({
    required String conversationId,
    required String messageId,
    required ChatMessageStatus status,
  }) {
    final messages = _messages(conversationId);
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    messages[index] = messages[index].copyWith(status: status);
    _emitMessages(conversationId);
  }

  void _appendMessage(String conversationId, ChatMessageModel message) {
    final messages = _messages(conversationId);
    final exists = messages.any((m) => m.id == message.id);
    if (exists) return;

    messages.add(message);
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _emitMessages(conversationId);
  }

  void _updateConversationFromMessage({
    required String conversationId,
    required ChatMessageModel message,
    required bool sentByMe,
    bool incrementUnread = false,
  }) {
    final existing = _conversationsById[conversationId];
    if (existing == null) return;

    _conversationsById[conversationId] = existing.copyWith(
      lastMessage: message.text,
      lastMessageTime: message.timestamp,
      isMyLastMessage: sentByMe,
      unreadCount: incrementUnread ? existing.unreadCount + 1 : existing.unreadCount,
    );
    _emitConversations();
  }

  List<ChatMessageModel> _messages(String conversationId) =>
      _messagesByConversation.putIfAbsent(conversationId, () => <ChatMessageModel>[]);

  void _emitMessages(String conversationId) {
    final controller = _messagesControllers.putIfAbsent(
      conversationId,
      () => StreamController<List<ChatMessageModel>>.broadcast(),
    );
    controller.add(List<ChatMessageModel>.from(_messages(conversationId)));
  }

  void _emitConversations() {
    final list = _conversationsById.values.toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    _conversationsController.add(list);
  }

  String _ticketPrefsKey(String userId) => 'skillchain_chat_tickets_$userId';

  Future<void> _loadTicketMapForUser(String userId) async {
    final switching =
        _lastTicketMapUserId.isNotEmpty && _lastTicketMapUserId != userId;
    if (switching) {
      _ticketIdByConversation.clear();
      _roomIdByTicketKey.clear();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_ticketPrefsKey(userId));
      if (raw == null || raw.isEmpty) {
        _lastTicketMapUserId = userId;
        return;
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>?;
      if (decoded == null) {
        _lastTicketMapUserId = userId;
        return;
      }
      decoded.forEach((k, v) {
        final ticket = _decodeStoredTicketValue(v);
        _ticketIdByConversation[k] = ticket;
        final key = _ticketKey(ticket);
        if (key.isNotEmpty) _roomIdByTicketKey[key] = k;
      });
    } catch (e) {
      debugPrint('[Chat] load tickets failed: $e');
    }
    _lastTicketMapUserId = userId;
  }

  dynamic _decodeStoredTicketValue(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final n = int.tryParse(v);
      if (n != null) return n;
    }
    return v;
  }

  void _setTicketMapping(String conversationId, dynamic ticketId) {
    _ticketIdByConversation[conversationId] = ticketId;
    final key = _ticketKey(ticketId);
    if (key.isNotEmpty) _roomIdByTicketKey[key] = conversationId;
    unawaited(_persistTicketMap());
  }

  Future<void> _persistTicketMap() async {
    try {
      final uid = _currentUserId;
      final prefs = await SharedPreferences.getInstance();
      final out = <String, dynamic>{};
      for (final e in _ticketIdByConversation.entries) {
        final v = e.value;
        if (v is int) {
          out[e.key] = v;
        } else if (v is num) {
          out[e.key] = v.toInt();
        } else if (v is String) {
          final n = int.tryParse(v);
          out[e.key] = n ?? v;
        } else {
          out[e.key] = v;
        }
      }
      await prefs.setString(_ticketPrefsKey(uid), jsonEncode(out));
    } catch (e) {
      debugPrint('[Chat] persist tickets failed: $e');
    }
  }

  Future<void> _persistRoomIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'skillchain_chat_room_peers_$_currentUserId';
      await prefs.setString(key, jsonEncode(_otherUserIdByRoom));
    } catch (_) {}
  }
}
