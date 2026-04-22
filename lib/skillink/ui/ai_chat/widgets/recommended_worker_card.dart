import 'package:flutter/material.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';

class RecommendedWorkerCard extends StatelessWidget {
  const RecommendedWorkerCard({
    super.key,
    required this.worker,
    required this.onViewProfile,
    required this.onBookNow,
    this.tradeLabel,
    this.reasonBlurb,
  });

  final Worker worker;
  final VoidCallback onViewProfile;
  final VoidCallback onBookNow;

  final String? tradeLabel;

  final String? reasonBlurb;

  static String _formatTrade(String slug) {
    switch (slug.toLowerCase()) {
      case 'hvac':
        return 'HVAC';
      case 'electrician':
        return 'Electrician';
      case 'plumber':
        return 'Plumber';
      case 'carpenter':
        return 'Carpenter';
      default:
        if (slug.isEmpty) return slug;
        return slug[0].toUpperCase() + slug.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.82,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.5),
          width: 1.5,
        ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14.5),
                topRight: Radius.circular(14.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  'Recommended for you',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (tradeLabel != null && tradeLabel!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _formatTrade(tradeLabel!),
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RoundAvatar(
                      url: worker.avatarUrl,
                      radius: 22,
                      placeholder: const Icon(Icons.person,
                          size: 20, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  worker.name,
                                  style: AppTypography.titleLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (worker.verificationStatus) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified,
                                    size: 14, color: AppColors.primary),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 13, color: AppColors.accent),
                              const SizedBox(width: 2),
                              Text(
                                '${worker.rating.toStringAsFixed(1)} (${worker.reviewCount})',
                                style: AppTypography.labelMedium,
                              ),
                              if (worker.distanceKm != null) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.location_on,
                                    size: 13, color: AppColors.textMuted),
                                const SizedBox(width: 2),
                                Text(
                                  '${worker.distanceKm!.toStringAsFixed(1)} km',
                                  style: AppTypography.labelMedium,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (worker.hourlyRate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Rs ${worker.hourlyRate!.toStringAsFixed(0)}/hr',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
                if (reasonBlurb != null && reasonBlurb!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 14, color: AppColors.accent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            reasonBlurb!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onViewProfile,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('View Profile',
                            style: AppTypography.labelMedium),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onBookNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Book Now',
                            style: AppTypography.labelMedium
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
