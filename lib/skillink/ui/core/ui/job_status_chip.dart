import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';

class JobStatusChip extends StatelessWidget {
  const JobStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(color: color),
      ),
    );
  }

  static (String, Color) _resolve(String status) {
    return switch (status) {
      'posted' => ('Posted', AppColors.textMuted),
      'workerAccepted' => ('Interested', AppColors.primary),
      'bidReceived' => ('Bid Received', AppColors.accent),
      'bidAccepted' => ('Bid Accepted', AppColors.primary),
      'onTheWay' => ('On The Way', AppColors.accent),
      'arrived' => ('Arrived', AppColors.primary),
      'inProgress' => ('In Progress', AppColors.warning),
      'completed' => ('Completed', AppColors.success),
      'cancelledNoPenalty' => ('Cancelled', AppColors.textMuted),
      'cancelledWithPenalty' => ('Cancelled', AppColors.danger),
      _ => (status, AppColors.textMuted),
    };
  }
}
