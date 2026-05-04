import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/chat_message.dart';
import 'package:skilllink/skillink/domain/models/chat_summary.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/ui/chat/view_models/chat_list_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_scaffold.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    final me = ref.read(authViewModelProvider).user;
    if (me == null) return;
    try {
      await ref.read(chatRepositoryProvider).refreshUserChats(me.id);
    } catch (_) {
      // Swallow — the stream will still surface fresh data when it arrives,
      // and any persistent failure is reported by the StreamProvider's
      // error state.
    }
    ref.invalidate(chatListViewModelProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider);
    final me = auth.user;
    final stream = ref.watch(chatListViewModelProvider);

    return AppScaffold(
      title: 'Messages',
      body: auth.bootstrapping
          ? const LoadingShimmerList(itemCount: 6)
          : me == null
          ? const EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'Sign in to chat',
              subtitle: 'Your conversations with workers and homeowners will appear here.',
            )
          : RefreshIndicator(
              onRefresh: () => _onRefresh(ref),
              color: AppColors.primary,
              child: stream.when(
                loading: () => const _ChatListLoading(),
                error: (e, _) => _ScrollableFill(
                  child: ErrorView(
                    message: 'Could not load chats.',
                    onRetry: () => ref.invalidate(chatListViewModelProvider),
                  ),
                ),
                data: (chats) {
                  // Hide shells for chats that have never exchanged a
                  // message, and force most-recent-first ordering so a new
                  // incoming message bumps that conversation to the top.
                  final visible = chats
                      .where((c) => c.lastMessageAt != null)
                      .toList()
                    ..sort(
                      (a, b) => b.lastMessageAt!.compareTo(a.lastMessageAt!),
                    );
                  if (visible.isEmpty) {
                    return const _ScrollableFill(
                      child: EmptyState(
                        icon: Icons.chat_bubble_outline,
                        title: 'No conversations yet',
                        subtitle:
                            'Start chatting with a worker from their profile or a posted job.',
                      ),
                    );
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: 76,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (_, i) {
                      final chat = visible[i];
                      return _ChatRow(
                        chat: chat,
                        onTap: () =>
                            context.push(Routes.chatThread(chat.chatId)),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _ChatListLoading extends StatelessWidget {
  const _ChatListLoading();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: const [
        LoadingShimmerList(itemCount: 6),
        Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScrollableFill extends StatelessWidget {
  const _ScrollableFill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.chat, required this.onTap});

  final ChatSummary chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = _previewLabel(chat);
    final time = chat.lastMessageAt == null ? '' : _timeAgo(chat.lastMessageAt!);
    final unread = chat.unreadCount;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Avatar(name: chat.peerName, url: chat.peerAvatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.peerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (chat.peerRole == UserRole.worker) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified,
                            size: 14, color: AppColors.primary),
                      ],
                      if (time.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: AppTypography.labelMedium.copyWith(
                            color: unread > 0
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight: unread > 0 ? FontWeight.w600 : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            color: unread > 0
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontWeight: unread > 0 ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
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
    );
  }

  static String _previewLabel(ChatSummary c) {
    if (c.lastMessagePreview != null && c.lastMessagePreview!.isNotEmpty) {
      return c.lastMessagePreview!;
    }
    return switch (c.lastMessageType) {
      ChatMessageType.image => '[Image]',
      ChatMessageType.audio => '[Voice note]',
      ChatMessageType.text => 'Tap to start chatting',
      null => 'Tap to start chatting',
    };
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.url});

  final String name;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final fallback = CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        initial,
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final resolved = resolveActiveBackendMediaUrl(url);
    if (resolved == null) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: resolved,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
