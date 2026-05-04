import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/services/eta_service.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/marketplace/view_models/worker_profile_view_model.dart';

/// Renders a small "≈ Xmin · Y km" pill estimating travel time from the worker
/// to a service address.
///
/// Source-of-truth precedence (most accurate first):
///   1. Worker's last-known live GPS coordinate from
///      `/workerLocations/{workerId}` in RTDB. Used whenever a recent fix is
///      available — typically once a worker session is active or while a
///      bid is pending and the worker auto-publisher has shared a fix.
///   2. Worker's registered profile address (forward-geocoded). Used as a
///      fallback while no live fix is on record.
///
/// In both cases the underlying [EtaService] applies a road-correction factor
/// to the great-circle distance so the number reads closer to what a routing
/// app would show. Hidden entirely when neither origin source is available.
class EtaBadge extends ConsumerWidget {
  const EtaBadge({
    super.key,
    required this.workerId,
    required this.serviceAddress,
    this.dense = false,
    this.prefix,
  });

  final String workerId;
  final String serviceAddress;
  final bool dense;
  final String? prefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (serviceAddress.trim().isEmpty) return const SizedBox.shrink();

    final liveAsync = ref.watch(workerLiveLocationProvider(workerId));
    final live = liveAsync.value;

    // Prefer the live GPS fix when available — it reflects where the worker
    // actually is right now, not a static profile address.
    if (live != null) {
      final etaAsync = ref.watch(
        liveCoordinateEtaProvider(
          (
            workerLat: live.lat,
            workerLng: live.lng,
            serviceAddress: serviceAddress,
          ),
        ),
      );
      return _renderEta(etaAsync, isLive: true);
    }

    final state = ref.watch(workerProfileViewModelProvider(workerId));
    final loc = state.worker?.location?.trim();
    if (loc == null || loc.isEmpty) return const SizedBox.shrink();

    final etaAsync = ref.watch(
      preJobEtaProvider(
        (workerLocation: loc, serviceAddress: serviceAddress),
      ),
    );
    return _renderEta(etaAsync, isLive: false);
  }

  Widget _renderEta(AsyncValue<EtaResult?> etaAsync, {required bool isLive}) {
    return etaAsync.when(
      loading: () => const SizedBox(
        height: 14,
        width: 14,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (eta) {
        if (eta == null) return const SizedBox.shrink();
        final base =
            '~${eta.minutes} min · ${eta.distanceKm.toStringAsFixed(1)} km';
        final label = prefix == null ? base : '$prefix $base';
        final color = isLive ? AppColors.primary : AppColors.textMuted;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 6 : 8,
            vertical: dense ? 2 : 4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLive
                    ? Icons.directions_car_rounded
                    : Icons.place_outlined,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: color,
                  fontSize: dense ? 10 : 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isLive) ...[
                const SizedBox(width: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
