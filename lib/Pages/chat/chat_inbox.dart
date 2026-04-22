import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skilllink/Pages/chat/chat_page.dart';
import 'package:skilllink/Pages/profile/user_profile_detail_screen.dart';
import 'package:skilllink/Widgets/user_avatar.dart';
import 'package:intl/intl.dart';
import 'package:skilllink/models/chat_models.dart';
import 'package:skilllink/services/chat/chat_service.dart';

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  final ChatService _chatService = ChatService.instance;
  final TextEditingController _searchController = TextEditingController();
  List<ChatConversationPreview> _conversations = const [];
  bool _isLoading = true;
  bool _showSearch = false;
  String _searchQuery = '';
  ChatConnectionStatus _connection = ChatConnectionStatus.disconnected;
  StreamSubscription<List<ChatConversationPreview>>? _conversationsSub;
  StreamSubscription<ChatConnectionStatus>? _connectionSub;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _chatService.initialize();
    _connection = _chatService.status;
    _connectionSub = _chatService.watchConnection().listen((status) {
      if (!mounted) return;
      setState(() => _connection = status);
    });
    _conversationsSub = _chatService.watchConversations().listen((items) {
      if (!mounted) return;
      setState(() {
        _conversations = items;
        _isLoading = false;
      });
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEE').format(time);
    } else {
      return DateFormat('MMM d').format(time);
    }
  }

  @override
  void dispose() {
    _conversationsSub?.cancel();
    _connectionSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<ChatConversationPreview> get _filtered {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _conversations;
    return _conversations.where((c) {
      return c.participantName.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final showConnectionBanner =
        _connection == ChatConnectionStatus.connecting ||
            _connection == ChatConnectionStatus.disconnected;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search messages…',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              )
            : const Text(
                'Messages',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (showConnectionBanner) _buildConnectionBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: () => _chatService.refreshInbox(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: _filtered.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey.shade200,
                            indent: 80,
                          ),
                          itemBuilder: (context, index) {
                            final conversation = _filtered[index];
                            return _ConversationTile(
                              conversation: conversation,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      chatConversationId: conversation.id,
                                      chatUserId: conversation.participantId,
                                      chatUserName: conversation.participantName,
                                      chatUserAvatar:
                                          conversation.participantAvatar,
                                      isOnline: conversation.participantOnline,
                                    ),
                                  ),
                                );
                              },
                              formatTime: _formatTime,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBanner() {
    final isConnecting = _connection == ChatConnectionStatus.connecting;
    final label = isConnecting ? 'Connecting…' : 'Offline';
    final color = isConnecting ? Colors.orange.shade700 : Colors.grey.shade700;
    final bg = isConnecting ? Colors.orange.shade50 : Colors.grey.shade100;
    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: isConnecting
                ? CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  )
                : Icon(Icons.cloud_off, size: 12, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final isSearching = _searchQuery.trim().isNotEmpty;
    return RefreshIndicator(
      onRefresh: () => _chatService.refreshInbox(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
        children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off : Icons.chat_bubble_outline,
                color: Colors.blue.shade700,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              isSearching ? 'No matches' : 'No conversations yet',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              isSearching
                  ? 'Try a different name or phrase.'
                  : 'Message someone from a post or accepted bid to start a chat.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversationPreview conversation;
  final VoidCallback onTap;
  final String Function(DateTime) formatTime;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadCount > 0;
    final lastPrefix = conversation.isMyLastMessage ? 'You: ' : '';
    final lastText = conversation.lastMessage.trim().isEmpty
        ? 'Tap to start chatting'
        : '$lastPrefix${conversation.lastMessage}';
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: conversation.participantId.isEmpty
                    ? null
                    : () => openUserProfileDetail(
                          context,
                          conversation.participantId,
                        ),
                child: Stack(
                  children: [
                    UserAvatar(
                      imageRef: conversation.participantAvatar.trim().isEmpty
                          ? null
                          : conversation.participantAvatar,
                      radius: 26,
                      backgroundColor: Colors.blue.shade50,
                    ),
                    if (conversation.participantOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.participantName,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatTime(conversation.lastMessageTime),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: unread
                                ? Colors.blue.shade700
                                : Colors.grey.shade600,
                            fontWeight: unread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastText,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: unread
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                              fontWeight:
                                  unread ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 22),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Text(
                              conversation.unreadCount > 99
                                  ? '99+'
                                  : conversation.unreadCount.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
