import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';
import 'package:skilllink/skillink/config/app_constants.dart';

class WorkerCard extends StatelessWidget {
  const WorkerCard({
    super.key,
    required this.name,
    required this.services,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    this.avatarUrl,
    this.isVerified = false,
    this.onTap,
    this.showTrailingChevron = true,
  });

  final String name;

  final List<String> services;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final String? avatarUrl;
  final bool isVerified;
  final VoidCallback? onTap;

  final bool showTrailingChevron;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _WorkerCardAvatar(avatarUrl: avatarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: AppTypography.titleLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      _WorkerServicesWrap(labels: services),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '${rating.toStringAsFixed(1)} ($reviewCount)',
                              style: AppTypography.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _DistanceLabel(distanceKm: distanceKm),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showTrailingChevron)
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkerCardAvatar extends StatelessWidget {
  const _WorkerCardAvatar({this.avatarUrl});

  final String? avatarUrl;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: _size / 2,
        backgroundColor: AppColors.shimmerBase,
        child: const Icon(Icons.person, color: AppColors.textMuted),
      );
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        placeholder: (_, _) => ColoredBox(
          color: AppColors.shimmerBase,
          child: const SizedBox(width: _size, height: _size),
        ),
        errorWidget: (_, _, _) => ColoredBox(
          color: AppColors.shimmerBase,
          child: const Icon(Icons.person, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _WorkerServicesWrap extends StatelessWidget {
  const _WorkerServicesWrap({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final list = labels.isEmpty ? const ['Technician'] : labels;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: list
          .map(
            (label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.shimmerBase.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: AppTypography.bodySmall,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DistanceLabel extends StatelessWidget {
  const _DistanceLabel({required this.distanceKm});

  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;

    if (distanceKm <= AppConstants.distanceNearby) {
      label = 'Nearby';
      color = AppColors.nearbyGreen;
    } else if (distanceKm <= AppConstants.distanceABitFar) {
      label = 'A bit far';
      color = AppColors.aBitFarAmber;
    } else {
      label = 'Too far';
      color = AppColors.tooFarRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}
