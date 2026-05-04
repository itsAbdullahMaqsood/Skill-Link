import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class BidAmountResult {
  const BidAmountResult({required this.amount, required this.visitingFee});
  final num amount;
  final num visitingFee;
  String get currency => 'PKR';
}

Future<BidAmountResult?> showBidAmountSheet(
  BuildContext context, {
  required String title,
  required String ctaLabel,
  num? suggestedAmount,
  num? suggestedVisitingFee,
  String? helperText,
}) {
  return showModalBottomSheet<BidAmountResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _BidAmountSheet(
      title: title,
      ctaLabel: ctaLabel,
      suggestedAmount: suggestedAmount,
      suggestedVisitingFee: suggestedVisitingFee,
      helperText: helperText,
    ),
  );
}

class _BidAmountSheet extends StatefulWidget {
  const _BidAmountSheet({
    required this.title,
    required this.ctaLabel,
    required this.suggestedAmount,
    required this.suggestedVisitingFee,
    required this.helperText,
  });

  final String title;
  final String ctaLabel;
  final num? suggestedAmount;
  final num? suggestedVisitingFee;
  final String? helperText;

  @override
  State<_BidAmountSheet> createState() => _BidAmountSheetState();
}

class _BidAmountSheetState extends State<_BidAmountSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _visitCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: _seedText(widget.suggestedAmount),
    );
    _visitCtrl = TextEditingController(
      text: _seedText(widget.suggestedVisitingFee),
    );
    _amountCtrl.addListener(_onChanged);
    _visitCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _visitCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  String _seedText(num? n) {
    if (n == null || n == 0) return '';
    return n == n.truncate() ? n.toInt().toString() : n.toString();
  }

  num? _parsedAmount() => num.tryParse(_amountCtrl.text.trim());
  num? _parsedVisit() => num.tryParse(_visitCtrl.text.trim());

  void _submit() {
    FocusScope.of(context).unfocus();
    final amt = _parsedAmount();
    final vis = _parsedVisit();
    if (amt == null || amt <= 0) {
      setState(() => _error = 'Enter a positive labour amount');
      return;
    }
    if (vis == null || vis < 0) {
      setState(() => _error = 'Enter a valid visiting fee (0 or more)');
      return;
    }
    Navigator.of(context)
        .pop(BidAmountResult(amount: amt, visitingFee: vis));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final amt = _parsedAmount() ?? 0;
    final vis = _parsedVisit() ?? 0;
    final total = amt + vis;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(widget.title, style: AppTypography.headlineMedium),
          if (widget.helperText != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.helperText!,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 18),
          _AmountField(
            label: 'Labour amount',
            controller: _amountCtrl,
            autofocus: true,
            errorText: _error,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          _AmountField(
            label: 'Visiting fee',
            controller: _visitCtrl,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 14),
          _TotalRow(total: total),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: Text(widget.ctaLabel,
                  style: AppTypography.titleLarge
                      .copyWith(color: Colors.white, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.label,
    required this.controller,
    this.autofocus = false,
    this.errorText,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final bool autofocus;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      style: AppTypography.titleLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'PKR  ',
        errorText: errorText,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.total});
  final num total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text('Total', style: AppTypography.bodyMedium),
          const Spacer(),
          Text(
            'PKR ${_format(total)}',
            style: AppTypography.titleLarge,
          ),
        ],
      ),
    );
  }

  static String _format(num n) {
    final i = n.toInt();
    final s = i.toString();
    final buf = StringBuffer();
    for (var idx = 0; idx < s.length; idx++) {
      if (idx > 0 && (s.length - idx) % 3 == 0) buf.write(',');
      buf.write(s[idx]);
    }
    return buf.toString();
  }
}
