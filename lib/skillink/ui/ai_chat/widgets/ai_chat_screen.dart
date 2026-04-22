import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/ai_message.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/ai_chat/view_models/ai_chat_view_model.dart';
import 'package:skilllink/skillink/ui/ai_chat/widgets/recommended_worker_card.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

const _suggestedPrompts = <String>[
  'My AC is leaking water',
  'Light keeps flickering',
  'Washing machine is shaking',
  'Pipe is leaking under sink',
  'Fridge is not cooling',
  'Door hinge is broken',
];

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(aiChatViewModelProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final isDraftSend = text == null;
    final msg = text ?? _controller.text;
    if (msg.trim().isEmpty) return;
    ref.read(aiChatViewModelProvider.notifier).sendMessage(msg);
    if (isDraftSend) _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiChatViewModelProvider);

    ref.listen<AiChatState>(aiChatViewModelProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) < next.messages.length) {
        _scrollToBottom();
      }
      if (prev?.failedMessageId != next.failedMessageId &&
          next.failedMessageId != null) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Text('SkillLink Assistant', style: AppTypography.headlineMedium),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? _EmptyState(onPromptTap: _send)
                : _MessageList(
                    messages: state.messages,
                    isTyping: state.isTyping,
                    reasonBlurbs: state.reasonBlurbs,
                    failedMessageId: state.failedMessageId,
                    scrollController: _scrollController,
                  ),
          ),
          _InputBar(
            controller: _controller,
            onSend: () => _send(),
            enabled: !state.isTyping,
          ),
        ],
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onPromptTap});

  final ValueChanged<String> onPromptTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Hi! I\'m your SkillLink Assistant.',
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Describe an appliance issue and I\'ll help you diagnose it — '
            'or match you with a verified technician.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Text('Try asking about:', style: AppTypography.labelLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _suggestedPrompts.map((prompt) {
              return ActionChip(
                label: Text(prompt, style: AppTypography.bodySmall),
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () => onPromptTap(prompt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}


class _MessageList extends ConsumerWidget {
  const _MessageList({
    required this.messages,
    required this.isTyping,
    required this.reasonBlurbs,
    required this.failedMessageId,
    required this.scrollController,
  });

  final List<AiMessage> messages;
  final bool isTyping;
  final Map<String, String> reasonBlurbs;
  final String? failedMessageId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <Widget>[];
    for (final msg in messages) {
      items.add(_ChatMessageBubble(message: msg));

      if (msg.role == AiMessageRole.user && msg.id == failedMessageId) {
        items.add(
          _RetryBanner(
            onRetry: () =>
                ref.read(aiChatViewModelProvider.notifier).retryFailedMessage(),
          ),
        );
      }

      if (msg.role == AiMessageRole.ai && msg.recommendedWorker != null) {
        items.add(
          Align(
            alignment: Alignment.centerLeft,
            child: RecommendedWorkerCard(
              worker: msg.recommendedWorker!,
              tradeLabel: msg.suggestedTrade,
              reasonBlurb: reasonBlurbs[msg.id],
              onViewProfile: () =>
                  context.push(Routes.workerProfile(msg.recommendedWorker!.id)),
              onBookNow: () =>
                  context.push(Routes.booking(msg.recommendedWorker!.id)),
            ),
          ),
        );
      }

      if (msg.role == AiMessageRole.ai &&
          msg.recommendedWorker == null &&
          msg.suggestedTrade != null) {
        items.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.go(Routes.marketplace(trade: msg.suggestedTrade)),
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Browse Technicians'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    if (isTyping) {
      items.add(const _TypingIndicator());
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (_, index) => items[index],
    );
  }
}


class _RetryBanner extends StatelessWidget {
  const _RetryBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.08),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 14, color: AppColors.danger),
            const SizedBox(width: 6),
            Text(
              'Failed to send.',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.danger,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 14, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Text(
                      'Retry',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({required this.message});

  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AiMessageRole.user;
    final time =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:'
        '${message.createdAt.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUser)
              Text(
                message.content,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              )
            else
              MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  strong: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  listBullet: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  em: AppTypography.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                  ),
                ),
                softLineBreak: true,
              ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: AppTypography.labelMedium.copyWith(
                  fontSize: 10,
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.2;
                final t = ((_anim.value + delay) % 1.0);
                final scale = 0.5 + 0.5 * _bounce(t);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  static double _bounce(double t) {
    if (t < 0.5) return 4 * t * t * t;
    return 1 - ((-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2)) / 2;
  }
}


class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.enabled,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.viewPaddingOf(context).bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, -2),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Describe your issue...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) {
              final canSend = enabled && value.text.trim().isNotEmpty;
              return IconButton(
                onPressed: canSend ? onSend : null,
                icon: const Icon(Icons.send_rounded),
                color: AppColors.primary,
                disabledColor: AppColors.textMuted.withValues(alpha: 0.4),
              );
            },
          ),
        ],
      ),
    );
  }
}
