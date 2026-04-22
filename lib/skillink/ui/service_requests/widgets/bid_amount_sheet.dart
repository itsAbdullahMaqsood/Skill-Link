import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class BidAmountResult {
  const BidAmountResult({required this.amount, required this.currency});
  final num amount;
  final String currency;
}

Future<BidAmountResult?> showBidAmountSheet(
  BuildContext context, {
  required String title,
  required String ctaLabel,
  num? suggestedAmount,
  String defaultCurrency = 'PKR',
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
      defaultCurrency: defaultCurrency,
      helperText: helperText,
    ),
  );
}

class _BidAmountSheet extends StatefulWidget {
  const _BidAmountSheet({
    required this.title,
    required this.ctaLabel,
    required this.suggestedAmount,
    required this.defaultCurrency,
    required this.helperText,
  });

  final String title;
  final String ctaLabel;
  final num? suggestedAmount;
  final String defaultCurrency;
  final String? helperText;

  @override
  State<_BidAmountSheet> createState() => _BidAmountSheetState();
}

class _BidAmountSheetState extends State<_BidAmountSheet> {
  late final TextEditingController _amountCtrl;
  late String _currency;
  String? _error;

  static const _currencies = <String>['PKR', 'USD'];

  @override
  void initState() {
    super.initState();
    final seed = widget.suggestedAmount;
    _amountCtrl = TextEditingController(
      text: seed == null || seed == 0 ? '' : _formatSeed(seed),
    );
    _currency = widget.defaultCurrency;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  String _formatSeed(num n) =>
      n == n.truncate() ? n.toInt().toString() : n.toString();

  void _submit() {
    FocusScope.of(context).unfocus();
    final raw = _amountCtrl.text.trim();
    final parsed = num.tryParse(raw);
    if (parsed == null || parsed <= 0) {
      setState(() => _error = 'Enter a positive amount');
      return;
    }
    Navigator.of(context)
        .pop(BidAmountResult(amount: parsed, currency: _currency));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _amountCtrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  style: AppTypography.titleLarge,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    errorText: _error,
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _currency,
                  items: _currencies
                      .map((c) =>
                          DropdownMenuItem<String>(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _currency = v ?? _currency),
                  decoration: InputDecoration(
                    labelText: 'Currency',
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
                ),
              ),
            ],
          ),
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
