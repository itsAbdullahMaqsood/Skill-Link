import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_back_scope.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/job_status_chip.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/utils/text_format.dart';

class _WorkerOngoingCombined {
  const _WorkerOngoingCombined({
    required this.jobs,
    required this.serviceRequests,
  });

  final List<Job> jobs;
  final List<ServiceRequest> serviceRequests;

  bool get isEmpty => jobs.isEmpty && serviceRequests.isEmpty;
}

final _workerOngoingCombinedProvider =
    FutureProvider.autoDispose<_WorkerOngoingCombined>((ref) async {
  final jobsRes = await ref.read(jobRepositoryProvider).listJobs();
  final srRes = await ref
      .read(serviceRequestRepositoryProvider)
      .listMyRequests(role: ServiceRequestRole.worker);

  final jobs = jobsRes.when(
    success: (list) => list
        .where(
          (j) =>
              j.status.isActive &&
              !(j.status == JobStatus.posted && j.workerId == null),
        )
        .toList(growable: false),
    failure: (msg, _) => throw Exception(msg),
  );
  final serviceRequests = srRes.when(
    success: (list) =>
        list.where((r) => r.showsAsWorkerOngoingJob).toList(growable: false),
    failure: (msg, _) => throw Exception(msg),
  );

  return _WorkerOngoingCombined(jobs: jobs, serviceRequests: serviceRequests);
});

String _chipKeyForServiceRequestStatus(ServiceRequestStatus s) {
  return switch (s) {
    ServiceRequestStatus.posted => 'posted',
    ServiceRequestStatus.workerAccepted => 'workerAccepted',
    ServiceRequestStatus.bidReceived => 'bidReceived',
    ServiceRequestStatus.bidAccepted => 'bidAccepted',
    ServiceRequestStatus.onTheWay => 'onTheWay',
    ServiceRequestStatus.arrived => 'arrived',
    ServiceRequestStatus.inProgress => 'inProgress',
    ServiceRequestStatus.completed => 'completed',
    ServiceRequestStatus.cancelled => 'cancelledNoPenalty',
    ServiceRequestStatus.unknown => 'posted',
  };
}

class WorkerOngoingJobsScreen extends ConsumerWidget {
  const WorkerOngoingJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_workerOngoingCombinedProvider);

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
          onRefresh: () async {
            ref.invalidate(myServiceRequestsProvider(ServiceRequestRole.worker));
            ref.invalidate(_workerOngoingCombinedProvider);
            await ref.read(_workerOngoingCombinedProvider.future);
          },
          child: async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingShimmerList(),
            ),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(_workerOngoingCombinedProvider),
            ),
            data: (combined) {
              if (combined.isEmpty) {
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
              final tiles = <Widget>[];
              for (final r in combined.serviceRequests) {
                tiles.add(
                  _OngoingServiceRequestTile(
                    request: r,
                    onTap: () =>
                        context.push(Routes.receivedRequestDetail(r.id)),
                  ),
                );
                tiles.add(const SizedBox(height: 10));
              }
              for (final j in combined.jobs) {
                tiles.add(
                  _OngoingTile(
                    job: j,
                    onTap: () => context.push(Routes.jobTracking(j.jobId)),
                  ),
                );
                tiles.add(const SizedBox(height: 10));
              }
              if (tiles.isNotEmpty) tiles.removeLast();

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: tiles,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OngoingServiceRequestTile extends StatelessWidget {
  const _OngoingServiceRequestTile({
    required this.request,
    required this.onTap,
  });

  final ServiceRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = request.description.trim().isEmpty
        ? 'Service request'
        : request.description.trim();
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
                  Icons.assignment_turned_in_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.serviceAddress,
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              JobStatusChip(
                status: _chipKeyForServiceRequestStatus(request.status),
              ),
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
