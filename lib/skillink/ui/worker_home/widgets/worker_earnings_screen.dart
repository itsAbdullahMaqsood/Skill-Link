import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/worker_home/view_models/worker_earnings_view_model.dart';
import 'package:skilllink/skillink/utils/text_format.dart';

class WorkerEarningsScreen extends ConsumerWidget {
  const WorkerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workerEarningsViewModelProvider);
    final vm = ref.read(workerEarningsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Earnings', style: AppTypography.headlineMedium),
      ),
      body: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingShimmer(height: 200),
            )
          : state.errorMessage != null
              ? ErrorView(
                  message: state.errorMessage!,
                  onRetry: vm.refresh,
                )
          : state.summary == null
              ? const EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'No earnings yet',
                  subtitle: 'Complete a job to see your earnings here.',
                )
          : (state.summary!.totalNet == 0 &&
                  state.summary!.completedJobs.isEmpty)
              ? RefreshIndicator(
                  onRefresh: vm.refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      EmptyState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'No earnings yet',
                        subtitle: 'Complete a job to see your earnings here.',
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: vm.refresh,
                  child: _Content(summary: state.summary!),
                ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.summary});

  final EarningsSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF2D4FA0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total earned (all time)',
                style: AppTypography.bodyMedium
                    .copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'PKR ${summary.totalNet.toStringAsFixed(0)}',
                style: AppTypography.headlineLarge
                    .copyWith(color: Colors.white, fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                'Net after 10% platform fee',
                style: AppTypography.bodySmall
                    .copyWith(color: Colors.white60),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatPill(
                    label: 'Gross',
                    value: 'PKR ${summary.totalGross.toStringAsFixed(0)}',
                  ),
                  const SizedBox(width: 10),
                  _StatPill(
                    label: 'Fee',
                    value: 'PKR ${summary.totalFee.toStringAsFixed(0)}',
                  ),
                ],
              ),
              if (summary.thisMonthNet > 0 ||
                  summary.thisMonthGross > 0) ...[
                const SizedBox(height: 14),
                Text(
                  'This month: net PKR ${summary.thisMonthNet.toStringAsFixed(0)} '
                  '(gross ${summary.thisMonthGross.toStringAsFixed(0)})',
                  style: AppTypography.bodySmall
                      .copyWith(color: Colors.white60),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text('Completed Jobs', style: AppTypography.titleLarge),
        const SizedBox(height: 10),

        if (summary.completedJobs.isEmpty)
          const EmptyState(
            icon: Icons.work_off_outlined,
            title: 'No completed jobs',
            subtitle: 'When you finish a job, it will show here with the amount.',
          )
        else
          for (final job in summary.completedJobs) ...[
            _EarningsRow(job: job),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.labelMedium
                  .copyWith(color: Colors.white60)),
          Text(value,
              style: AppTypography.labelLarge
                  .copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

class _EarningsRow extends StatelessWidget {
  const _EarningsRow({required this.job});

  final EarningsJob job;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 2),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconFor(job.serviceType),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(TextFormat.trade(job.serviceType),
                    style: AppTypography.titleLarge),
                const SizedBox(height: 2),
                Text(
                  _daysAgo(job.completedAt),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Net PKR ${job.net.toStringAsFixed(0)}',
                style: AppTypography.titleLarge
                    .copyWith(color: AppColors.success),
              ),
              Text(
                'Gross ${job.gross.toStringAsFixed(0)} · fee ${job.fee.toStringAsFixed(0)}',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: job.paid
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  job.paid ? 'Paid' : 'Pending',
                  style: AppTypography.labelMedium.copyWith(
                    color: job.paid ? AppColors.success : AppColors.accent,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(String type) => switch (type.toLowerCase()) {
        'electrician' => Icons.electrical_services_rounded,
        'plumber' => Icons.plumbing_rounded,
        'hvac' || 'ac' => Icons.ac_unit_rounded,
        'carpenter' => Icons.carpenter_rounded,
        _ => Icons.handyman_rounded,
      };

  static String _daysAgo(DateTime dt) {
    final days = DateTime.now().difference(dt).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }
}
