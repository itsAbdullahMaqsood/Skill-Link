import 'package:flutter/material.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/utils/text_format.dart';

class BidModal extends StatefulWidget {
  const BidModal({
    super.key,
    required this.job,
    required this.onSubmit,
    this.isCounterOffer = false,
  });

  final Job job;
  final ValueChanged<double> onSubmit;
  final bool isCounterOffer;

  @override
  State<BidModal> createState() => _BidModalState();
}

class _BidModalState extends State<BidModal> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    widget.onSubmit(amount);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isCounterOffer ? 'Counter-offer' : 'Submit Your Bid',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '${TextFormat.trade(widget.job.serviceType)} — '
            '${widget.job.description}',
            style: AppTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Your price (PKR)',
            hint: 'e.g. 2500',
            controller: _controller,
            keyboardType: TextInputType.number,
            validator: (_) => _error,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 8),
          Text(
            '10% platform fee will be deducted from your earnings.',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: widget.isCounterOffer ? 'Send Counter' : 'Submit Bid',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
