import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class VoiceNoteRecorder extends StatefulWidget {
  const VoiceNoteRecorder({super.key, required this.onPath});

  final void Function(String path) onPath;

  @override
  State<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<VoiceNoteRecorder> {
  final _audioRecorder = AudioRecorder();
  bool _recording = false;
  Duration _elapsed = Duration.zero;
  DateTime? _started;

  @override
  void dispose() {
    unawaited(_audioRecorder.dispose());
    super.dispose();
  }

  Future<void> _start() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) return;
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    setState(() {
      _recording = true;
      _started = DateTime.now();
      _elapsed = Duration.zero;
    });
    _tick();
  }

  void _tick() {
    if (!_recording || _started == null) return;
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (!mounted || !_recording || _started == null) return;
      setState(() {
        _elapsed = DateTime.now().difference(_started!);
      });
      _tick();
    });
  }

  Future<void> _stop() async {
    if (!_recording) return;
    final path = await _audioRecorder.stop();
    setState(() {
      _recording = false;
      _started = null;
    });
    if (path != null && File(path).existsSync()) {
      widget.onPath(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSec = _elapsed.inSeconds;
    final mm = (totalSec ~/ 60).toString().padLeft(2, '0');
    final ss = (totalSec % 60).toString().padLeft(2, '0');
    return Listener(
      onPointerDown: (_) => _start(),
      onPointerUp: (_) => _stop(),
      onPointerCancel: (_) => _stop(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _recording
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              _recording ? Icons.mic_rounded : Icons.mic_none_rounded,
              size: 36,
              color: _recording ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              _recording ? 'Release to save' : 'Press and hold to record',
              style: AppTypography.labelLarge,
            ),
            if (_recording) Text('$mm:$ss', style: AppTypography.titleLarge),
          ],
        ),
      ),
    );
  }
}
