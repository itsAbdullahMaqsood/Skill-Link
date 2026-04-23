import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/chat/chat_entry.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_back_scope.dart';
import 'package:skilllink/skillink/ui/core/ui/bid_card.dart';
import 'package:skilllink/skillink/ui/core/ui/cancel_job_dialog.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/job_status_chip.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/secondary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/status_timeline.dart';
import 'package:skilllink/skillink/ui/job_tracking/view_models/job_tracking_view_model.dart';
import 'package:skilllink/skillink/ui/job_tracking/widgets/live_worker_map.dart';
import 'package:skilllink/skillink/ui/marketplace/view_models/worker_profile_view_model.dart';
import 'package:skilllink/skillink/utils/text_format.dart';
import 'package:url_launcher/url_launcher.dart';

class JobTrackingScreen extends ConsumerWidget {
  const JobTrackingScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = jobTrackingViewModelProvider(jobId);
    final state = ref.watch(provider);
    final vm = ref.read(provider.notifier);

    ref.listen<JobTrackingState>(provider, (prev, next) {
      final msg = next.errorMessage;
      if (msg != null && msg != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
        vm.clearError();
      }
      final outcome = next.cancellationPenaltyApplied;
      if (outcome != null && outcome != prev?.cancellationPenaltyApplied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(outcome
                ? 'Job cancelled. A cancellation fee may apply.'
                : 'Job cancelled — no penalty.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        vm.clearCancellationOutcome();
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
          title: const Text('Job'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(Routes.homeownerHome),
          ),
        ),
        body: _Body(state: state, vm: vm),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state, required this.vm});
  final JobTrackingState state;
  final JobTrackingViewModel vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.job == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final job = state.job;
    if (job == null) {
      return ErrorView(
        message: state.errorMessage ?? 'Could not load this job.',
        onRetry: vm.retry,
      );
    }

    final viewerRole = ref.watch(authViewModelProvider).user?.role;
    final isWorker = viewerRole == UserRole.worker;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        _HeaderCard(job: job),
        const SizedBox(height: 16),
        if (job.status.isActive) ...[
          LiveWorkerMap(
            locationStream: vm.watchLocation(),
            homeLocation: _homeLocationFor(job),
          ),
          const SizedBox(height: 16),
        ],
        _Section(
          title: 'Status',
          child: StatusTimeline(
            job: job,
            role: isWorker ? TimelineRole.worker : TimelineRole.homeowner,
          ),
        ),
        if (job.bidHistory.isNotEmpty) ...[
          const SizedBox(height: 16),
          BidCard(
            job: job,
            isBusy: state.isBusy,
            onAccept: () => vm.acceptBid(vm.pendingWorkerBid?.bidId),
            onCounter: () => _openCounterSheet(context, state, vm),
          ),
        ],
        const SizedBox(height: 16),
        _DetailsCard(job: job),
        const SizedBox(height: 20),
        _ActionButtons(state: state, vm: vm),
      ],
    );
  }

  Future<void> _openCounterSheet(
    BuildContext context,
    JobTrackingState state,
    JobTrackingViewModel vm,
  ) async {
    final controller = TextEditingController();
    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Counter-offer', style: AppTypography.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(
                  prefixText: 'PKR ',
                  labelText: 'Your offer',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Send counter-offer',
                onPressed: () {
                  final v = double.tryParse(controller.text.trim());
                  if (v == null || v <= 0) return;
                  Navigator.of(ctx).pop(v);
                },
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (amount != null) vm.counterOffer(amount);
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.job});
  final Job job;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
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
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.payments_outlined,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                job.finalPrice == null
                    ? 'Awaiting bid'
                    : 'PKR ${job.finalPrice!.toStringAsFixed(0)}',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                _scheduled(job.scheduledDate),
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _scheduled(DateTime d) {
    final hh = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final am = d.hour < 12 ? 'AM' : 'PM';
    return '${d.day}/${d.month} · $hh $am';
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.job});
  final Job job;

  @override
  Widget build(BuildContext context) {
    final addr = job.address;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Text(
            job.description,
            style: AppTypography.bodyMedium,
          ),
          if (job.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: job.photoUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: _imageProvider(job.photoUrls[i]),
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 76,
                      height: 76,
                      color: AppColors.border,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined,
                          color: AppColors.textMuted, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${addr.street}, ${addr.area}\n${addr.city} ${addr.postalCode}',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.credit_card,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                '${job.paymentMethod.displayName}'
                '${job.paid ? ' · Paid' : ''}',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  ImageProvider _imageProvider(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    return FileImage(File(path));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.state, required this.vm});
  final JobTrackingState state;
  final JobTrackingViewModel vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = state.job!;
    final children = <Widget>[];

    final worker = job.workerId == null
        ? null
        : ref.watch(workerProfileViewModelProvider(job.workerId!)).worker;
    final workerPhone = worker?.phone;

    if (job.workerId != null &&
        !job.status.isCancelled &&
        job.status != JobStatus.completed) {
      children.add(Row(
        children: [
          Expanded(
            child: SecondaryButton(
              label: 'Message',
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: worker == null
                  ? null
                  : () => ChatEntry.openWithWorker(context, ref, worker: worker),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SecondaryButton(
              label: 'Call',
              icon: Icons.call,
              onPressed: workerPhone == null ? null : () => _dial(workerPhone),
            ),
          ),
        ],
      ));
      children.add(const SizedBox(height: 8));
    }

    if (state.canMarkPaid) {
      children.add(PrimaryButton(
        label: 'Mark as paid',
        icon: Icons.check_circle_outline,
        onPressed: state.isBusy ? null : vm.markAsPaid,
        isLoading: state.isBusy,
      ));
      children.add(const SizedBox(height: 8));
    }

    if (job.status == JobStatus.completed && job.paid) {
      children.add(PrimaryButton(
        label: 'Rate & review',
        icon: Icons.star_outline,
        onPressed: () =>
            context.push(Routes.rateJob(job.jobId)),
      ));
      children.add(const SizedBox(height: 8));
    }

    if (state.canCancel) {
      children.add(SecondaryButton(
        label: state.inCancellationGrace
            ? 'Cancel (no penalty)'
            : 'Cancel job',
        icon: Icons.close_rounded,
        onPressed: state.isBusy
            ? null
            : () async {
                final confirmed = await CancelJobDialog.show(
                  context,
                  jobCreatedAt: job.createdAt,
                );
                if (confirmed) vm.cancel();
              },
      ));
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Future<void> _dial(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

({double lat, double lng}) _homeLocationFor(Job job) {
  const seedLat = 31.5204;
  const seedLng = 74.3587;

  final hash = job.jobId.hashCode;
  final latOffset = ((hash % 20) - 10) * 0.001;
  final lngOffset = (((hash >> 5) % 20) - 10) * 0.001;
  return (lat: seedLat + latOffset, lng: seedLng + lngOffset);
}
