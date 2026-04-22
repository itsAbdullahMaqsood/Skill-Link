import 'package:flutter/material.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

enum TimelineRole { homeowner, worker }

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({
    super.key,
    this.status,
    this.job,
    this.role = TimelineRole.homeowner,
  }) : assert(status != null || job != null,
            'Pass at least one of `status` or `job` to StatusTimeline.');

  final JobStatus? status;

  final Job? job;

  final TimelineRole role;

  static const List<JobStatus> _homeownerFlow = [
    JobStatus.posted,
    JobStatus.workerAccepted,
    JobStatus.bidReceived,
    JobStatus.bidAccepted,
    JobStatus.onTheWay,
    JobStatus.arrived,
    JobStatus.inProgress,
    JobStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final resolvedStatus = status ?? job!.status;
    if (resolvedStatus.isCancelled) {
      return _buildCancelledTimeline(resolvedStatus);
    }
    return role == TimelineRole.worker
        ? _buildWorkerTimeline()
        : _buildHomeownerTimeline(resolvedStatus);
  }


  Widget _buildHomeownerTimeline(JobStatus s) {
    final currentIndex = _homeownerFlow.indexOf(s);
    return Column(
      children: [
        for (var i = 0; i < _homeownerFlow.length; i++)
          _TimelineRow(
            label: _homeownerFlow[i].displayName,
            state: i < currentIndex
                ? _RowState.done
                : i == currentIndex
                    ? _RowState.current
                    : _RowState.pending,
            isLast: i == _homeownerFlow.length - 1,
          ),
      ],
    );
  }


  Widget _buildWorkerTimeline() {
    final currentIndex = _workerStepFor(job, status);
    const labels = <String>[
      'Job Initiated',
      'Arrived',
      'In Progress',
      'Homeowner Paid',
      'Completed',
    ];
    return Column(
      children: [
        for (var i = 0; i < labels.length; i++)
          _TimelineRow(
            label: labels[i],
            state: i < currentIndex
                ? _RowState.done
                : i == currentIndex
                    ? _RowState.current
                    : _RowState.pending,
            isLast: i == labels.length - 1,
          ),
      ],
    );
  }

  static int _workerStepFor(Job? job, JobStatus? status) {
    final s = job?.status ?? status!;
    final paid = job?.paid ?? false;
    if (s == JobStatus.completed) {
      return paid ? 4 : 3;
    }
    if (s == JobStatus.inProgress) return 2;
    if (s == JobStatus.arrived) return 1;
    return 0;
  }

  Widget _buildCancelledTimeline(JobStatus s) {
    return Column(
      children: [
        _TimelineRow(
          label: 'Posted',
          state: _RowState.done,
          isLast: false,
        ),
        _TimelineRow(
          label: s == JobStatus.cancelledWithPenalty
              ? 'Cancelled (penalty applied)'
              : 'Cancelled',
          state: _RowState.cancelled,
          isLast: true,
        ),
      ],
    );
  }
}

enum _RowState { done, current, pending, cancelled }

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.state,
    required this.isLast,
  });

  final String label;
  final _RowState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = switch (state) {
      _RowState.done => AppColors.primary,
      _RowState.current => AppColors.primary,
      _RowState.pending => AppColors.border,
      _RowState.cancelled => AppColors.danger,
    };
    final labelColor = state == _RowState.pending
        ? AppColors.textMuted
        : AppColors.textPrimary;
    final lineColor = state == _RowState.pending
        ? AppColors.border
        : AppColors.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 4),
                _Dot(color: dotColor, filled: state != _RowState.pending),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: labelColor,
                  fontWeight: state == _RowState.current
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color, width: 2),
        shape: BoxShape.circle,
      ),
    );
  }
}
