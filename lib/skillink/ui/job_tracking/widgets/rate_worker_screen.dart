import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_back_scope.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/job_tracking/view_models/review_view_model.dart';
import 'package:skilllink/skillink/utils/app_messenger.dart';

class RateWorkerScreen extends ConsumerStatefulWidget {
  const RateWorkerScreen({super.key, required this.jobId});
  final String jobId;

  @override
  ConsumerState<RateWorkerScreen> createState() => _RateWorkerScreenState();
}

class _RateWorkerScreenState extends ConsumerState<RateWorkerScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = reviewViewModelProvider(widget.jobId);
    final state = ref.watch(provider);
    final vm = ref.read(provider.notifier);

    ref.listen<ReviewState>(provider, (prev, next) {
      final msg = next.errorMessage;
      if (msg != null && msg != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      }
      if (next.isSubmitted && prev?.isSubmitted != true) {
        context.go(Routes.homeownerHome);
        appScaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Thanks for your feedback!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return AppBackScope(
      fallbackPath: Routes.homeownerHome,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Rate worker'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(Routes.homeownerHome),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How was the job?',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your rating stays anonymous. The worker only sees the score.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                Center(
                  child: _StarRow(
                    rating: state.rating,
                    onChanged: vm.setRating,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Leave a comment (optional)',
                  controller: _commentCtrl,
                  hint: 'e.g. Arrived on time, explained the issue clearly…',
                  maxLines: 4,
                  onChanged: vm.setComment,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Submit review',
                    isLoading: state.isSubmitting,
                    onPressed: state.canSubmit && !state.isSubmitting
                        ? () => vm.submit()
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.onChanged});
  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return IconButton(
          iconSize: 44,
          onPressed: () => onChanged(i + 1),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? AppColors.accent : AppColors.border,
          ),
        );
      }),
    );
  }
}
