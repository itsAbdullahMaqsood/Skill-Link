import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/chat/view_models/chat_thread_view_model.dart';
import 'package:skilllink/skillink/ui/chat/widgets/chat_input_bar.dart';
import 'package:skilllink/skillink/ui/chat/widgets/chat_message_bubble.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen>
    with WidgetsBindingObserver {
  final _scroll = ScrollController();
  bool _registeredFocus = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(currentChatIdProvider.notifier).state = widget.chatId;
      _registeredFocus = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed && _registeredFocus) {
      ref.read(currentChatIdProvider.notifier).state = widget.chatId;
      unawaited(
        ref.read(chatThreadViewModelProvider(widget.chatId).notifier).markRead(),
      );
    } else if (state == AppLifecycleState.paused && _registeredFocus) {
      ref.read(currentChatIdProvider.notifier).state = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_registeredFocus) {
      try {
        final container = ProviderScope.containerOf(context, listen: false);
        final notifier = container.read(currentChatIdProvider.notifier);
        if (notifier.state == widget.chatId) {
          notifier.state = null;
        }
      } catch (_) {
      }
    }
    _scroll.dispose();
    super.dispose();
  }

  void _maybeAutoScroll(int newCount) {
    if (newCount <= _lastMessageCount) {
      _lastMessageCount = newCount;
      return;
    }
    _lastMessageCount = newCount;
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final atBottom = position.pixels >= position.maxScrollExtent - 80;
    if (!atBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatThreadViewModelProvider(widget.chatId));
    final vm = ref.read(chatThreadViewModelProvider(widget.chatId).notifier);
    final me = ref.watch(authViewModelProvider).user?.id ?? '';

    ref.listen<String?>(
      chatThreadViewModelProvider(widget.chatId).select((s) => s.errorMessage),
      (_, next) {
        if (next == null || next.isEmpty) return;
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
        vm.clearError();
      },
    );

    _maybeAutoScroll(state.messages.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _ChatAppBar(state: state),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: state.bootstrapping && state.messages.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : state.messages.isEmpty
                      ? _EmptyThread(peerName: state.peer?.peerName ?? 'this user')
                      : _MessageList(
                          state: state,
                          me: me,
                          scroll: _scroll,
                          onLoadEarlier: vm.loadEarlier,
                        ),
            ),
            ChatInputBar(
              isSending: state.isSending,
              onSendText: vm.sendText,
              onPickImage: vm.sendImage,
              onSendAudio: (file, ms) => vm.sendAudio(file, durationMs: ms),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.state});

  final ChatThreadState state;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final peer = state.peer;
    final name = peer?.peerName ?? 'Chat';
    final avatar = peer?.peerAvatar;
    final role = peer?.peerRole;

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          _HeaderAvatar(name: name, url: avatar),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (role == UserRole.worker) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          size: 14, color: AppColors.primary),
                    ],
                  ],
                ),
                Text(
                  role == UserRole.worker
                      ? 'Worker'
                      : role == UserRole.homeowner
                          ? 'Homeowner'
                          : '',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.name, this.url});

  final String name;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final fallback = CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        initial,
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
    if (url == null || url!.isEmpty || !url!.startsWith('http')) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.state,
    required this.me,
    required this.scroll,
    required this.onLoadEarlier,
  });

  final ChatThreadState state;
  final String me;
  final ScrollController scroll;
  final Future<void> Function() onLoadEarlier;

  @override
  Widget build(BuildContext context) {
    final messages = state.messages;
    final showLoadEarlier = state.hasMoreEarlier && messages.isNotEmpty;
    final extra = showLoadEarlier ? 1 : 0;

    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: messages.length + extra,
      itemBuilder: (ctx, i) {
        if (showLoadEarlier && i == 0) {
          return _LoadEarlierTile(
            isLoading: state.isLoadingEarlier,
            onTap: onLoadEarlier,
          );
        }
        final idx = i - extra;
        final message = messages[idx];
        final showDayHeader = idx == 0 ||
            !_sameDay(messages[idx - 1].sentAt, message.sentAt);
        return Column(
          children: [
            if (showDayHeader) _DayHeader(date: message.sentAt),
            ChatMessageBubble(
              message: message,
              isMine: message.senderId == me,
            ),
          ],
        );
      },
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _LoadEarlierTile extends StatelessWidget {
  const _LoadEarlierTile({required this.isLoading, required this.onTap});

  final bool isLoading;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: TextButton(
          onPressed: isLoading ? null : onTap,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Load earlier messages',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            _format(date),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  static String _format(DateTime d) {
    final today = DateTime.now();
    final isToday = today.year == d.year && today.month == d.month && today.day == d.day;
    if (isToday) return 'Today';
    final yesterday = today.subtract(const Duration(days: 1));
    if (yesterday.year == d.year &&
        yesterday.month == d.month &&
        yesterday.day == d.day) {
      return 'Yesterday';
    }
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread({required this.peerName});

  final String peerName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Say hello to $peerName',
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Send a text, photo, or voice note to start the conversation.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
