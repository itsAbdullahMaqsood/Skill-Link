import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/secondary_button.dart';

class CancelJobDialog extends StatefulWidget {
  const CancelJobDialog({super.key, required this.jobCreatedAt});

  final DateTime jobCreatedAt;

  static Future<bool> show(
    BuildContext context, {
    required DateTime jobCreatedAt,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => CancelJobDialog(jobCreatedAt: jobCreatedAt),
    );
    return confirmed ?? false;
  }

  @override
  State<CancelJobDialog> createState() => _CancelJobDialogState();
}

class _CancelJobDialogState extends State<CancelJobDialog> {
  Timer? _ticker;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _computeRemaining();
    if (_remaining > Duration.zero) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        final next = _computeRemaining();
        if (!mounted) return;
        setState(() => _remaining = next);
        if (next <= Duration.zero) _ticker?.cancel();
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration _computeRemaining() {
    final elapsed = DateTime.now().difference(widget.jobCreatedAt);
    final r = AppConstants.cancellationGracePeriod - elapsed;
    return r.isNegative ? Duration.zero : r;
  }

  @override
  Widget build(BuildContext context) {
    final inGrace = _remaining > Duration.zero;
    final iconColor = inGrace ? AppColors.warning : AppColors.danger;
    final title = inGrace ? 'Cancel — no penalty' : 'Cancel with penalty';
    final body = inGrace
        ? 'You can still cancel for free. This grace period ends in '
            '${_formatDuration(_remaining)}.'
        : 'The grace period has ended. Cancelling now may apply a '
            'cancellation fee per our terms.';

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleLarge
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      content: Text(
        body,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Keep job',
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: 'Cancel job',
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}
