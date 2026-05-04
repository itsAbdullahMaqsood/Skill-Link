import 'package:flutter/material.dart';
import 'package:skilllink/models/user.dart' as sc;
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class WorkerProfileWarningBanner extends StatelessWidget {
  const WorkerProfileWarningBanner({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.danger, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your recent rating is ${rating.toStringAsFixed(1)}. '
              'Account will be suspended below '
              '${AppConstants.suspensionThreshold.toStringAsFixed(1)}.',
              style:
                  AppTypography.bodySmall.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerProfileReviewTile extends StatelessWidget {
  const WorkerProfileReviewTile({super.key, required this.review});

  final Review review;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Anonymous Homeowner',
                  style: AppTypography.titleLarge),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= review.rating.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: AppColors.accent,
                    ),
                ],
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.comment!, style: AppTypography.bodyMedium),
          ],
          const SizedBox(height: 4),
          Text(
            _daysAgo(review.createdAt),
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  static String _daysAgo(DateTime dt) {
    final days = DateTime.now().difference(dt).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }
}

class WorkerAccountStatusRow extends StatelessWidget {
  const WorkerAccountStatusRow({super.key, required this.labour});

  final sc.UserModel? labour;

  @override
  Widget build(BuildContext context) {
    final u = labour;
    if (u == null) return const SizedBox.shrink();

    final status = u.status.trim();
    final verified = u.verified;
    final chips = <Widget>[
      _StatusPill(
        icon: Icons.construction_rounded,
        label: 'Worker',
        background: AppColors.primary.withValues(alpha: 0.08),
        foreground: AppColors.primary,
      ),
      if (status.isNotEmpty)
        _StatusPill(
          icon: status.toLowerCase() == 'approved'
              ? Icons.check_circle_outline_rounded
              : Icons.hourglass_top_rounded,
          label: _capitalize(status),
          background: (status.toLowerCase() == 'approved'
                  ? AppColors.success
                  : AppColors.warning)
              .withValues(alpha: 0.10),
          foreground: status.toLowerCase() == 'approved'
              ? AppColors.success
              : AppColors.warning,
        ),
      if (verified)
        _StatusPill(
          icon: Icons.verified_rounded,
          label: 'Verified',
          background: AppColors.success.withValues(alpha: 0.10),
          foreground: AppColors.success,
        ),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: chips,
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerProfileInfoTile extends StatelessWidget {
  const WorkerProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMuted),
      title: Text(
        label,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      ),
      subtitle: Text(value, style: AppTypography.bodyMedium),
      dense: true,
    );
  }
}
