import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/open_jobs/view_models/bid_submit_view_model.dart';
import 'package:skilllink/skillink/utils/app_messenger.dart';

class BidSheet extends ConsumerStatefulWidget {
  const BidSheet({super.key, required this.job});

  final PostedJob job;

  @override
  ConsumerState<BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends ConsumerState<BidSheet> {
  final _visit = TextEditingController();
  final _job = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _visit.dispose();
    _job.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(bidSubmitViewModelProvider(widget.job));
    final vm = ref.read(bidSubmitViewModelProvider(widget.job).notifier);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Place your bid', style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Text(widget.job.title, style: AppTypography.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  tooltip: 'Refresh ETA',
                  onPressed: vm.refreshEta,
                  icon: st.isEtaLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
                Expanded(
                  child: Text(
                    st.etaMinutes == null
                        ? 'ETA unavailable'
                        : 'About ${st.etaMinutes} minutes away',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _visit,
              label: 'Visiting charges (Rs)',
              keyboardType: TextInputType.number,
              onChanged: vm.setVisiting,
            ),
            const SizedBox(height: 4),
            Text(
              'Charge for visiting the site and assessing the problem.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _job,
              label: 'Job charges estimate (Rs)',
              keyboardType: TextInputType.number,
              onChanged: vm.setJobEstimate,
            ),
            const SizedBox(height: 4),
            Text(
              'Estimated total cost if you take the job.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _note,
              label: 'Note (optional)',
              maxLines: 2,
              onChanged: vm.setNote,
            ),
            if (st.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  st.errorMessage!,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
                ),
              ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Submit bid',
              isLoading: st.isSubmitting,
              onPressed: () async {
                vm.setVisiting(_visit.text);
                vm.setJobEstimate(_job.text);
                vm.setNote(_note.text);
                final err = await vm.submit();
                if (!context.mounted) return;
                if (err == null) {
                  Navigator.pop(context);
                  appScaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(content: Text('Bid submitted.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
