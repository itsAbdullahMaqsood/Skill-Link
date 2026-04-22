import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_back_scope.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/job_status_chip.dart';
import 'package:skilllink/skillink/ui/job_tracking/view_models/job_history_view_model.dart';
import 'package:skilllink/skillink/utils/text_format.dart';
import 'package:skilllink/skillink/utils/trade_icon.dart';

class JobHistoryScreen extends ConsumerWidget {
  const JobHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobHistoryViewModelProvider);
    final vm = ref.read(jobHistoryViewModelProvider.notifier);

    return AppBackScope(
      fallbackPath: Routes.homeownerHome,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Your Jobs'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(Routes.homeownerHome),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: vm.refresh,
          child: state.when(
            skipLoadingOnReload: true,
            data: (jobs) {
              if (jobs.isEmpty) {
                return LayoutBuilder(
                  builder: (_, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: const EmptyState(
                        icon: Icons.history_toggle_off,
                        title: 'No jobs yet',
                        subtitle:
                            'Book your first worker from the marketplace.',
                      ),
                    ),
                  ),
                );
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: jobs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _HistoryTile(job: jobs[i]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => ErrorView(
              message: err is String ? err : err.toString(),
              onRetry: vm.refresh,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.job});
  final Job job;

  @override
  Widget build(BuildContext context) {
    final canRate = job.status == JobStatus.completed && job.paid;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(Routes.jobTracking(job.jobId)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  TradeIcon.forTrade(job.serviceType),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            TextFormat.trade(job.serviceType),
                            style: AppTypography.titleLarge,
                          ),
                        ),
                        JobStatusChip(status: job.status.name),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(job),
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (canRate) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () =>
                            context.push(Routes.rateJob(job.jobId)),
                        child: Row(
                          children: [
                            const Icon(Icons.star_outline,
                                size: 16, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              'Rate & review',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(Job job) {
    final date =
        '${job.scheduledDate.day}/${job.scheduledDate.month}/${job.scheduledDate.year}';
    final price =
        job.finalPrice == null ? '—' : 'PKR ${job.finalPrice!.toStringAsFixed(0)}';
    return '$date · $price';
  }
}
