import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class AudioMessagePlayer extends StatefulWidget {
  const AudioMessagePlayer({
    super.key,
    required this.url,
    this.durationMs,
    required this.tintColor,
    required this.foregroundColor,
  });

  final String url;
  final int? durationMs;
  final Color tintColor;
  final Color foregroundColor;

  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  final _player = AudioPlayer();
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration? _total;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.durationMs != null) {
      _total = Duration(milliseconds: widget.durationMs!);
    }
    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });
    _posSub = _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    });
    _durSub = _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _total = d);
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _position = Duration.zero;
      });
    });
  }

  Future<void> _toggle() async {
    if (_failed && mounted) setState(() => _failed = false);
    try {
      if (_playing) {
        await _player.pause();
      } else {
        if (widget.url.startsWith('http')) {
          await _player.play(UrlSource(widget.url));
        } else if (widget.url.startsWith('file://')) {
          final path = Uri.parse(widget.url).toFilePath();
          await _player.play(DeviceFileSource(path));
        } else {
          await _player.play(DeviceFileSource(widget.url));
        }
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final total = _total ?? Duration.zero;
    final progress = (total.inMilliseconds == 0)
        ? 0.0
        : (_position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

    return SizedBox(
      width: 220,
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.tintColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _failed
                    ? Icons.error_outline
                    : (_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                color: widget.foregroundColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: widget.foregroundColor.withValues(alpha: 0.25),
                    valueColor: AlwaysStoppedAnimation(widget.foregroundColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _failed
                      ? 'Tap to retry'
                      : (total > Duration.zero
                          ? '${_fmt(_position)} / ${_fmt(total)}'
                          : 'Voice note'),
                  style: AppTypography.labelMedium.copyWith(
                    fontSize: 11,
                    color: widget.foregroundColor.withValues(alpha: 0.85),
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

class AudioBubblePalette {
  const AudioBubblePalette({
    required this.tint,
    required this.foreground,
  });

  final Color tint;
  final Color foreground;

  factory AudioBubblePalette.forUser({required bool isMine}) {
    return isMine
        ? AudioBubblePalette(
            tint: Colors.white.withValues(alpha: 0.25),
            foreground: Colors.white,
          )
        : const AudioBubblePalette(
            tint: AppColors.primary,
            foreground: Colors.white,
          );
  }
}
