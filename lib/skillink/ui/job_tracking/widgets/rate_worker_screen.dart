import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_back_scope.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/job_tracking/view_models/review_view_model.dart';
import 'package:skilllink/skillink/utils/app_messenger.dart';

class _RateScreenCopy {
  const _RateScreenCopy({
    required this.appBarTitle,
    required this.headline,
    required this.subtitle,
    required this.commentHint,
    required this.homeRoute,
  });

  final String appBarTitle;
  final String headline;
  final String subtitle;
  final String commentHint;
  final String homeRoute;

  factory _RateScreenCopy.forRole(UserRole role) => switch (role) {
        UserRole.worker => const _RateScreenCopy(
            appBarTitle: 'Rate customer',
            headline: 'How was this customer?',
            subtitle:
                'Your rating stays anonymous. The customer only sees the score.',
            commentHint: 'e.g. Clear instructions, respectful, paid on time…',
            homeRoute: Routes.workerJobs,
          ),
        UserRole.homeowner => const _RateScreenCopy(
            appBarTitle: 'Rate worker',
            headline: 'How was the job?',
            subtitle:
                'Your rating stays anonymous. The worker only sees the score.',
            commentHint:
                'e.g. Arrived on time, explained the issue clearly…',
            homeRoute: Routes.homeownerHome,
          ),
      };
}

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
    final role =
        ref.watch(authViewModelProvider).user?.role ?? UserRole.homeowner;
    final copy = _RateScreenCopy.forRole(role);

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
        context.go(copy.homeRoute);
        appScaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Thanks for your feedback!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return AppBackScope(
      fallbackPath: copy.homeRoute,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(copy.appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(copy.homeRoute),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.alreadyReviewed
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 64, color: AppColors.accent),
                            const SizedBox(height: 16),
                            Text('You already reviewed this job.',
                                style: AppTypography.headlineSmall),
                            const SizedBox(height: 8),
                            Text(
                              'Thanks for your feedback.',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: PrimaryButton(
                                label: 'Done',
                                onPressed: () => context.go(copy.homeRoute),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            copy.headline,
                            style: AppTypography.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            copy.subtitle,
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
                            hint: copy.commentHint,
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
