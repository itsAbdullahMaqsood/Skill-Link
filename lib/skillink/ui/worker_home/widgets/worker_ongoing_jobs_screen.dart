import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_back_scope.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/job_status_chip.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/utils/text_format.dart';

final _ongoingJobsProvider =
    FutureProvider.autoDispose<List<Job>>((ref) async {
  final repo = ref.read(jobRepositoryProvider);
  final res = await repo.listJobs();
  return res.when(
    success: (jobs) =>
        jobs.where((j) => j.status.isActive).toList(growable: false),
    failure: (msg, _) => throw Exception(msg),
  );
});

class WorkerOngoingJobsScreen extends ConsumerWidget {
  const WorkerOngoingJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_ongoingJobsProvider);

    return AppBackScope(
      fallbackPath: Routes.workerJobs,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(Routes.workerJobs),
          ),
          title: Text('Ongoing Jobs', style: AppTypography.headlineMedium),
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(_ongoingJobsProvider.future),
          child: async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingShimmerList(),
            ),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(_ongoingJobsProvider),
            ),
            data: (jobs) {
              if (jobs.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 80),
                    EmptyState(
                      icon: Icons.handyman_outlined,
                      title: 'No ongoing jobs',
                      subtitle:
                          'Accept a request or place a winning bid and it '
                          'will appear here while it\'s in flight.',
                    ),
                  ],
                );
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: jobs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final j = jobs[i];
                  return _OngoingTile(
                    job: j,
                    onTap: () => context.push(Routes.jobTracking(j.jobId)),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OngoingTile extends StatelessWidget {
  const _OngoingTile({required this.job, required this.onTap});

  final Job job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconFor(job.serviceType),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TextFormat.trade(job.serviceType),
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.description,
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              JobStatusChip(status: job.status.name),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(String type) => switch (type.toLowerCase()) {
      'electrician' || 'electrical' => Icons.electrical_services_rounded,
      'plumber' || 'plumbing' => Icons.plumbing_rounded,
      'hvac' || 'ac' => Icons.ac_unit_rounded,
      'carpenter' || 'carpentry' => Icons.carpenter_rounded,
      _ => Icons.handyman_rounded,
    };
