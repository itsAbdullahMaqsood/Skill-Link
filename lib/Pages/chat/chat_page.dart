import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skilllink/Pages/profile/user_profile_detail_screen.dart';
import 'package:skilllink/Widgets/user_avatar.dart';
import 'package:skilllink/models/chat_models.dart';
import 'package:skilllink/services/chat/chat_service.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final String currentUserId;
  final String? senderName;
  final String? senderAvatar;
  final bool showAvatar;
  final bool isGrouped;

  const ChatBubble({
    super.key,
    required this.message,
    required this.currentUserId,
    this.senderName,
    this.senderAvatar,
    this.showAvatar = true,
    this.isGrouped = false,
  });

  String _formatTime(DateTime time) {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(time.year, time.month, time.day);

      if (messageDate == today) {
        return DateFormat('HH:mm').format(time);
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday ${DateFormat('HH:mm').format(time)}';
      } else {
        return DateFormat('MMM d, HH:mm').format(time);
      }
    } catch (e) {
      return DateFormat('HH:mm').format(time);
    }
  }

  IconData _getStatusIcon(ChatMessageStatus status) {
    switch (status) {
      case ChatMessageStatus.sending:
        return Icons.access_time;
      case ChatMessageStatus.sent:
        return Icons.check;
      case ChatMessageStatus.delivered:
        return Icons.done_all;
      case ChatMessageStatus.read:
        return Icons.done_all;
      case ChatMessageStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor(ChatMessageStatus status) {
    switch (status) {
      case ChatMessageStatus.sending:
        return Colors.grey.shade400;
      case ChatMessageStatus.sent:
        return Colors.grey.shade400;
      case ChatMessageStatus.delivered:
        return Colors.grey.shade600;
      case ChatMessageStatus.read:
        return Colors.blue;
      case ChatMessageStatus.failed:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (message.isFrom(currentUserId)) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: const Radius.circular(18),
                        bottomRight: isGrouped
                            ? const Radius.circular(4)
                            : const Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _getStatusIcon(message.status),
                              size: 14,
                              color: _getStatusColor(message.status),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showAvatar && !isGrouped) ...[
              const SizedBox(width: 8),
              UserAvatar(
                imageRef: null,
                radius: 16,
                backgroundColor: Colors.grey.shade300,
              ),
            ] else if (!showAvatar && !isGrouped)
              const SizedBox(width: 40),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showAvatar && !isGrouped)
              UserAvatar(
                imageRef: senderAvatar,
                radius: 16,
                backgroundColor: Colors.grey.shade300,
              ),
            if (showAvatar && !isGrouped) const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isGrouped && senderName != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        senderName!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: isGrouped
                            ? const Radius.circular(4)
                            : const Radius.circular(18),
                        bottomRight: const Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!showAvatar && !isGrouped) const SizedBox(width: 40),
          ],
        ),
      );
    }
  }
}

class DateDivider extends StatelessWidget {
  final DateTime date;

  const DateDivider({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(date.year, date.month, date.day);

      String dateText;
      if (messageDate == today) {
        dateText = 'Today';
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        dateText = 'Yesterday';
      } else {
        dateText = DateFormat('MMMM d, yyyy').format(date);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                dateText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
      );
    } catch (e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                DateFormat('MMM d, yyyy').format(date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
      );
    }
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          UserAvatar(
            imageRef: null,
            radius: 16,
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animationValue = ((value + delay) % 1.0);
        final opacity = animationValue < 0.5
            ? animationValue * 2
            : 2 - (animationValue * 2);
        return Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String? chatConversationId;
  final String? chatUserId;
  final String? chatUserName;
  final String? chatUserAvatar;
  final bool isOnline;

  const ChatScreen({
    super.key,
    this.chatConversationId,
    this.chatUserId,
    this.chatUserName,
    this.chatUserAvatar,
    this.isOnline = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService.instance;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  StreamSubscription<List<ChatMessageModel>>? _messagesSub;
  StreamSubscription<bool>? _typingSub;
  StreamSubscription<ChatConnectionStatus>? _connectionSub;
  Timer? _typingDebounce;

  List<ChatMessageModel> _messages = const [];
  String? _conversationId;
  ChatConnectionStatus _socketStatus = ChatConnectionStatus.disconnected;
  String? _backendTicketId;
  bool _isRemoteTyping = false;
  bool _isBootstrapping = true;
  bool _isLoadingHistory = false;
  String? _bootstrapError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (mounted) {
      setState(() {
        _isBootstrapping = true;
        _isLoadingHistory = false;
        _bootstrapError = null;
      });
    }
    try {
      await _chatService.initialize();
      _socketStatus = _chatService.status;
      _connectionSub?.cancel();
      _connectionSub = _chatService.watchConnection().listen((status) {
        if (!mounted) return;
        setState(() => _socketStatus = status);
      });
      final participantId = (widget.chatUserId ?? '').trim();
      final participantName = widget.chatUserName ?? 'User';
      final participantAvatar = widget.chatUserAvatar ?? '';

      if (widget.chatConversationId == null && participantId.isEmpty) {
        throw StateError(
          'Missing participant — try opening the chat from their profile again.',
        );
      }

      final conversationId =
          widget.chatConversationId ??
          await _chatService.openOrCreateConversation(
            participantId: participantId,
            participantName: participantName,
            participantAvatar: participantAvatar,
            participantOnline: widget.isOnline,
          );

      if (widget.chatConversationId != null) {
        _chatService.ensureConversationShell(
          roomId: conversationId,
          otherUserId: participantId,
          otherName: participantName,
          otherAvatar: participantAvatar,
          participantOnline: widget.isOnline,
        );
      }

      _conversationId = conversationId;
      _chatService.setActiveConversation(conversationId);
      _backendTicketId = _chatService.getBackendTicketId(conversationId);
      debugPrint(
        '[Chat] conversationId=$conversationId '
        'backendTicket=${_backendTicketId ?? "(none yet — normal for new chats)"}',
      );
      _messagesSub = _chatService.watchMessages(conversationId).listen((items) {
        if (!mounted) return;
        setState(() => _messages = items);
        _scrollToBottom();
      });
      _typingSub = _chatService.watchTyping(conversationId).listen((isTyping) {
        if (!mounted) return;
        setState(() => _isRemoteTyping = isTyping);
      });
      await _chatService.markConversationAsRead(conversationId);

      if (!mounted) return;
      setState(() {
        _isBootstrapping = false;
        _isLoadingHistory = true;
      });

      await _chatService.fetchRoomHistory(conversationId);
    } catch (e) {
      debugPrint('[Chat] bootstrap failed: $e');
      if (!mounted) return;
      setState(() {
        _bootstrapError = _humanizeError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBootstrapping = false;
          _isLoadingHistory = false;
        });
      }
    }
  }

  String _humanizeError(Object e) {
    var msg = e.toString();
    if (msg.startsWith('Bad state: ')) msg = msg.substring('Bad state: '.length);
    if (msg.startsWith('Exception: ')) msg = msg.substring('Exception: '.length);
    final lower = msg.toLowerCase();
    if (lower.contains('internal server error') ||
        lower.contains('500')) {
      return "We couldn't open this chat right now. Please try again in a moment.";
    }
    if (lower.contains('socket') || lower.contains('network') ||
        lower.contains('timeout') || lower.contains('timed out')) {
      return 'Network hiccup — check your connection and retry.';
    }
    if (lower.contains('unauthori') || lower.contains('401')) {
      return 'Your session expired. Please sign in again.';
    }
    if (lower.contains('missing roomid')) {
      return "We couldn't open this chat room. Please try again in a moment.";
    }
    if (msg.trim().isEmpty) return 'Something went wrong opening this chat.';
    return msg;
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    final conversationId = _conversationId;
    if (text.isEmpty || conversationId == null) return;

    _controller.clear();
    await _chatService.sendMessage(
      conversationId: conversationId,
      text: text,
      recipientUserId: widget.chatUserId,
    );
    if (!mounted) return;
    setState(() {
      _backendTicketId = _chatService.getBackendTicketId(conversationId);
    });
    debugPrint(
      '[Chat] after send: conversationId=$conversationId '
      'backendTicket=$_backendTicketId',
    );
    _chatService.setTyping(conversationId: conversationId, isTyping: false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _shouldShowAvatar(int index) {
    if (index == 0) return true;
    final current = _messages[index];
    final previous = _messages[index - 1];
    final isCurrentMe = current.isFrom(_chatService.currentUserId);
    final isPreviousMe = previous.isFrom(_chatService.currentUserId);
    return isCurrentMe != isPreviousMe ||
        current.timestamp.difference(previous.timestamp).inMinutes > 5;
  }

  bool _isGrouped(int index) {
    if (index == 0) return false;
    final current = _messages[index];
    final previous = _messages[index - 1];
    final isCurrentMe = current.isFrom(_chatService.currentUserId);
    final isPreviousMe = previous.isFrom(_chatService.currentUserId);
    return isCurrentMe == isPreviousMe &&
        current.timestamp.difference(previous.timestamp).inMinutes <= 5;
  }

  String _statusLine(bool isOnline) {
    if (_isRemoteTyping) return 'Typing...';
    switch (_socketStatus) {
      case ChatConnectionStatus.connecting:
        return 'Connecting chat…';
      case ChatConnectionStatus.disconnected:
        return 'Chat offline';
      case ChatConnectionStatus.connected:
        return isOnline ? 'Online' : 'Offline';
    }
  }

  void _openParticipantProfile(BuildContext context) {
    final id = (widget.chatUserId ?? '').trim();
    openUserProfileDetail(context, id);
  }

  Color _statusLineColor(bool isOnline) {
    if (_isRemoteTyping) return Colors.blue;
    switch (_socketStatus) {
      case ChatConnectionStatus.connecting:
        return Colors.orange.shade800;
      case ChatConnectionStatus.disconnected:
        return Colors.redAccent;
      case ChatConnectionStatus.connected:
        return isOnline ? Colors.green : Colors.grey.shade600;
    }
  }

  bool _shouldShowDateDivider(int index) {
    if (index == 0) return true;
    final current = _messages[index];
    final previous = _messages[index - 1];
    final currentDate = DateTime(
      current.timestamp.year,
      current.timestamp.month,
      current.timestamp.day,
    );
    final previousDate = DateTime(
      previous.timestamp.year,
      previous.timestamp.month,
      previous.timestamp.day,
    );
    return currentDate != previousDate;
  }

  @override
  void dispose() {
    if (_conversationId != null) {
      _chatService.setActiveConversation(null);
    }
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _connectionSub?.cancel();
    _typingDebounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatUserName = widget.chatUserName ?? 'User';
    final chatUserAvatar = widget.chatUserAvatar ?? '';
    final isOnline = widget.isOnline;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: InkWell(
          onTap: () => _openParticipantProfile(context),
          child: Row(
            children: [
              Stack(
                children: [
                  UserAvatar(
                    imageRef:
                        chatUserAvatar.trim().isEmpty ? null : chatUserAvatar,
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatUserName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _statusLine(isOnline),
                      style: TextStyle(
                        color: _statusLineColor(isOnline),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.black),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'view_profile') {
                _openParticipantProfile(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('View Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'skill_exchange',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 20),
                    SizedBox(width: 8),
                    Text('Skill Exchange'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_chat',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear Chat', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isBootstrapping ||
                    (_isLoadingHistory && _messages.isEmpty)
                ? const Center(child: CircularProgressIndicator())
                : _bootstrapError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.blue.shade700,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Couldn't open this chat",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _bootstrapError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: _bootstrap,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length + (_isRemoteTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isRemoteTyping) {
                  return const TypingIndicator();
                }

                final message = _messages[index];
                final showAvatar = _shouldShowAvatar(index);
                final isGrouped = _isGrouped(index);
                final showDateDivider = _shouldShowDateDivider(index);

                return Column(
                  children: [
                    if (showDateDivider) DateDivider(date: message.timestamp),
                    ChatBubble(
                      message: message,
                      currentUserId: _chatService.currentUserId,
                      senderName: message.isFrom(_chatService.currentUserId)
                          ? null
                          : chatUserName,
                      senderAvatar: message.isFrom(_chatService.currentUserId)
                          ? null
                          : chatUserAvatar,
                      showAvatar: showAvatar,
                      isGrouped: isGrouped,
                    ),
                  ],
                );
              },
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onSubmitted: (_) => _sendMessage(),
                        onChanged: (text) {
                          final conversationId = _conversationId;
                          if (conversationId == null) return;
                          _chatService.setTyping(
                            conversationId: conversationId,
                            isTyping: text.trim().isNotEmpty,
                          );
                          _typingDebounce?.cancel();
                          _typingDebounce = Timer(
                            const Duration(seconds: 1),
                            () {
                              _chatService.setTyping(
                                conversationId: conversationId,
                                isTyping: false,
                              );
                            },
                          );
                        },
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
