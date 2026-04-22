import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/domain/models/open_job_post_bid.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/open_job_post/view_models/open_job_post_actions_controller.dart';

class OpenJobPostBidSheet extends ConsumerStatefulWidget {
  const OpenJobPostBidSheet({
    super.key,
    required this.post,
    this.existingBid,
  });

  final OpenJobPost post;
  final OpenJobPostBid? existingBid;

  static Future<bool?> show(
    BuildContext context, {
    required OpenJobPost post,
    OpenJobPostBid? existingBid,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => OpenJobPostBidSheet(post: post, existingBid: existingBid),
    );
  }

  @override
  ConsumerState<OpenJobPostBidSheet> createState() =>
      _OpenJobPostBidSheetState();
}

class _OpenJobPostBidSheetState extends ConsumerState<OpenJobPostBidSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.existingBid != null
          ? widget.existingBid!.amount.toString()
          : '',
    );
    _noteCtrl = TextEditingController(text: widget.existingBid?.note ?? '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingBid != null;
    final controller = ref
        .read(openJobPostActionsControllerProvider(widget.post.id).notifier);
    final state =
        ref.watch(openJobPostActionsControllerProvider(widget.post.id));
    final submitting =
        state.runningAction == OpenJobPostActionKind.submitBid;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              isEdit ? 'Update your bid' : 'Place a bid',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              isEdit
                  ? 'The homeowner will see the new amount immediately. Your '
                      'previous bid is overwritten.'
                  : 'Your bid stays pending until the homeowner either '
                      'selects you or picks another worker.',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _amountCtrl,
              label: 'Amount (PKR)',
              hint: 'e.g. 2500',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _noteCtrl,
              label: 'Note (optional)',
              hint: 'e.g. Price includes parts. Available after 2pm.',
              maxLines: 3,
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: isEdit ? 'Update bid' : 'Submit bid',
              icon: Icons.gavel_rounded,
              isLoading: submitting,
              onPressed: submitting
                  ? null
                  : () async {
                      final parsed = num.tryParse(_amountCtrl.text.trim());
                      if (parsed == null || parsed <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter a valid bid amount.'),
                          ),
                        );
                        return;
                      }
                      final outcome = await controller.submitBid(
                        amount: parsed,
                        currency: 'PKR',
                        note: _noteCtrl.text,
                      );
                      if (!context.mounted) return;
                      if (!outcome.isSuccess) return;
                      Navigator.of(context).pop(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEdit
                                ? 'Your bid has been updated.'
                                : 'Bid submitted. Good luck!',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed:
                  submitting ? null : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
