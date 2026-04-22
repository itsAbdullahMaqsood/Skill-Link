import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onPickImage,
    required this.onSendAudio,
    required this.isSending,
  });

  final Future<void> Function(String text) onSendText;
  final Future<void> Function(File image) onPickImage;
  final Future<void> Function(File audio, int durationMs) onSendAudio;
  final bool isSending;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();
  Timer? _tickTimer;
  bool _recording = false;

  bool _stopPendingAfterStart = false;
  bool _cancelPendingStop = false;

  bool _startingRecord = false;
  bool _cancelOnRelease = false;
  DateTime? _recordStarted;
  Duration _recordElapsed = Duration.zero;
  String? _recordingPath;

  @override
  void dispose() {
    _tickTimer?.cancel();
    _controller.dispose();
    _focus.dispose();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  Future<void> _attachImage() async {
    if (widget.isSending) return;
    final source = await _pickSource();
    if (source == null) return;
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1920,
    );
    if (file == null) return;
    await widget.onPickImage(File(file.path));
  }

  Future<ImageSource?> _pickSource() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pick from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;
    _controller.clear();
    await widget.onSendText(text);
  }

  Future<void> _startRecording() async {
    if (_recording || widget.isSending || _startingRecord) return;
    _startingRecord = true;
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      _startingRecord = false;
      return;
    }
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/chat_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    try {
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
    } catch (_) {
      _stopPendingAfterStart = false;
      _cancelPendingStop = false;
      _startingRecord = false;
      return;
    } finally {
      if (_startingRecord) _startingRecord = false;
    }
    if (!mounted) return;
    if (_stopPendingAfterStart) {
      _stopPendingAfterStart = false;
      final cancel = _cancelPendingStop;
      _cancelPendingStop = false;
      await _finalizeStopAfterStart(path: path, cancelled: cancel);
      return;
    }
    setState(() {
      _recording = true;
      _cancelOnRelease = false;
      _recordingPath = path;
      _recordStarted = DateTime.now();
      _recordElapsed = Duration.zero;
    });
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || !_recording || _recordStarted == null) return;
      setState(() {
        _recordElapsed = DateTime.now().difference(_recordStarted!);
      });
    });
  }

  Future<void> _finalizeStopAfterStart({
    required String path,
    required bool cancelled,
  }) async {
    _tickTimer?.cancel();
    String? pathOnDisk;
    try {
      pathOnDisk = await _recorder.stop();
    } catch (_) {
      pathOnDisk = null;
    }
    final usable = pathOnDisk ?? path;
    if (usable.isNotEmpty) {
      try {
        final f = File(usable);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    if (!mounted) return;
    if (cancelled) return;
  }

  Future<void> _stopRecording({required bool cancelled}) async {
    if (!_recording) {
      _stopPendingAfterStart = true;
      _cancelPendingStop = cancelled;
      return;
    }
    _tickTimer?.cancel();
    final pathOnDisk = await _recorder.stop();
    final elapsed = _recordElapsed;
    if (!mounted) return;
    setState(() {
      _recording = false;
      _recordStarted = null;
      _recordElapsed = Duration.zero;
      _cancelOnRelease = false;
    });

    final usable = pathOnDisk ?? _recordingPath;
    _recordingPath = null;
    if (cancelled || usable == null) {
      if (usable != null) {
        try {
          final f = File(usable);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
      return;
    }
    final f = File(usable);
    if (!await f.exists()) return;
    if (elapsed < const Duration(seconds: 1)) {
      try {
        await f.delete();
      } catch (_) {}
      return;
    }
    await widget.onSendAudio(f, elapsed.inMilliseconds);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: SafeArea(
        top: false,
        child: Padding(padding: const EdgeInsets.all(8), child: _buildBar()),
      ),
    );
  }

  Widget _buildBar() {
    final totalSec = _recordElapsed.inSeconds;
    final mm = (totalSec ~/ 60).toString().padLeft(2, '0');
    final ss = (totalSec % 60).toString().padLeft(2, '0');
    final accent = _cancelOnRelease ? AppColors.danger : AppColors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_recording) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danger,
              ),
            ),
          ),
          Text(
            '$mm:$ss',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _cancelOnRelease ? 'Release to cancel' : 'Slide left to cancel',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ] else ...[
          IconButton(
            tooltip: 'Attach image',
            onPressed: widget.isSending ? null : _attachImage,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            color: AppColors.textMuted,
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 4),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (_, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            if (!_recording && hasText) {
              return _CircleIconButton(
                color: AppColors.primary,
                icon: widget.isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                onPressed: widget.isSending ? null : _send,
              );
            }
            return Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: widget.isSending || _recording
                  ? null
                  : (_) => _startRecording(),
              onPointerMove: (event) {
                if (!_recording) return;
                final shouldCancel = event.delta.dx < -2 || _cancelOnRelease;
                if (shouldCancel != _cancelOnRelease) {
                  setState(() => _cancelOnRelease = shouldCancel);
                }
              },
              onPointerUp: (_) => _stopRecording(cancelled: _cancelOnRelease),
              onPointerCancel: (_) => _stopRecording(cancelled: true),
              child: _CircleIconButton(
                color: accent,
                icon: Icon(
                  _recording && _cancelOnRelease
                      ? Icons.delete_outline
                      : Icons.mic_rounded,
                  color: Colors.white,
                  size: _recording ? 22 : 20,
                ),
                onPressed: null,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  final Color color;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(width: 44, height: 44, child: Center(child: icon)),
      ),
    );
  }
}
