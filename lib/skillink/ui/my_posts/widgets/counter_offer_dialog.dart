import 'package:flutter/material.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';

class CounterOfferResult {
  const CounterOfferResult({
    required this.visiting,
    required this.jobEstimate,
    this.note,
  });

  final double visiting;
  final double jobEstimate;
  final String? note;
}

Future<CounterOfferResult?> showCounterOfferDialog(BuildContext context) {
  return showDialog<CounterOfferResult>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _CounterOfferDialogBody(),
  );
}

class _CounterOfferDialogBody extends StatefulWidget {
  const _CounterOfferDialogBody();

  @override
  State<_CounterOfferDialogBody> createState() =>
      _CounterOfferDialogBodyState();
}

class _CounterOfferDialogBodyState extends State<_CounterOfferDialogBody> {
  final _visitCtrl = TextEditingController();
  final _jobCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _visitCtrl.dispose();
    _jobCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  double? _parseAmount(String raw) {
    final cleaned = raw.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  void _onSend() {
    final v = _parseAmount(_visitCtrl.text);
    final j = _parseAmount(_jobCtrl.text);
    if (v == null || j == null) {
      setState(() => _error = 'Enter valid numbers for both amounts.');
      return;
    }
    if (v < 0 || j < 0) {
      setState(() => _error = 'Amounts cannot be negative.');
      return;
    }
    final note = _noteCtrl.text.trim();
    if (note.length > AppConstants.maxPostedBidNoteLength) {
      setState(() => _error =
          'Note is too long (max ${AppConstants.maxPostedBidNoteLength} chars).');
      return;
    }
    Navigator.pop(
      context,
      CounterOfferResult(
        visiting: v,
        jobEstimate: j,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Counter-offer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _visitCtrl,
              label: 'Visiting charges (Rs)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _jobCtrl,
              label: 'Job estimate (Rs)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _noteCtrl,
              label: 'Note (optional)',
              maxLines: 2,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _onSend,
          child: const Text('Send'),
        ),
      ],
    );
  }
}
