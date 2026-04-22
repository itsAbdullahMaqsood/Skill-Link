import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skilllink/skillink/domain/models/chat_message.dart';
import 'package:skilllink/skillink/ui/chat/widgets/audio_message_player.dart';
import 'package:skilllink/skillink/ui/chat/widgets/image_viewer_screen.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.showTimestamp = true,
  });

  final ChatMessage message;
  final bool isMine;
  final bool showTimestamp;

  @override
  Widget build(BuildContext context) {
    final align = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bg = isMine
        ? AppColors.primary
        : AppColors.primary.withValues(alpha: 0.06);
    final fg = isMine ? Colors.white : AppColors.textPrimary;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMine ? 16 : 4),
      bottomRight: Radius.circular(isMine ? 4 : 16),
    );

    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              switch (message.type) {
                ChatMessageType.text => _TextContent(text: message.text ?? '', fg: fg),
                ChatMessageType.image =>
                  _ImageContent(url: message.imageUrl ?? ''),
                ChatMessageType.audio => _AudioContent(
                    url: message.audioUrl ?? '',
                    durationMs: message.audioDurationMs,
                    isMine: isMine,
                  ),
              },
              if (showTimestamp)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                  child: Text(
                    _formatTime(message.sentAt),
                    style: AppTypography.labelMedium.copyWith(
                      fontSize: 10,
                      color: isMine
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $ampm';
  }
}

class _TextContent extends StatelessWidget {
  const _TextContent({required this.text, required this.fg});

  final String text;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(color: fg),
      ),
    );
  }
}

class _ImageContent extends StatelessWidget {
  const _ImageContent({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: url.isEmpty
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ImageViewerScreen(url: url),
                ),
              ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260),
        child: _renderImage(url),
      ),
    );
  }

  Widget _renderImage(String url) {
    if (url.isEmpty) {
      return Container(
        height: 180,
        color: AppColors.shimmerBase,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined,
            color: AppColors.textMuted, size: 36),
      );
    }
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          height: 180,
          color: AppColors.shimmerBase,
        ),
        errorWidget: (_, _, _) => Container(
          height: 180,
          color: AppColors.shimmerBase,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined,
              color: AppColors.textMuted, size: 36),
        ),
      );
    }
    final path = url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        height: 180,
        color: AppColors.shimmerBase,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined,
            color: AppColors.textMuted, size: 36),
      ),
    );
  }
}

class _AudioContent extends StatelessWidget {
  const _AudioContent({
    required this.url,
    required this.durationMs,
    required this.isMine,
  });

  final String url;
  final int? durationMs;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final palette = AudioBubblePalette.forUser(isMine: isMine);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: AudioMessagePlayer(
        url: url,
        durationMs: durationMs,
        tintColor: palette.tint,
        foregroundColor: palette.foreground,
      ),
    );
  }
}
