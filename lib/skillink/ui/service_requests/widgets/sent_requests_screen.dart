import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';

class SentRequestsScreen extends ConsumerWidget {
  const SentRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      myServiceRequestsProvider(ServiceRequestRole.customer),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Sent Requests', style: AppTypography.headlineMedium),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          myServiceRequestsProvider(ServiceRequestRole.customer).future,
        ),
        child: async.when(
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  EmptyState(
                    icon: Icons.outbox_outlined,
                    title: 'No requests yet',
                    subtitle:
                        'Requests you send to workers from the marketplace '
                        'will appear here.',
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final req = items[i];
                return SentRequestTile(
                  request: req,
                  onTap: () => context.push(Routes.sentRequestDetail(req.id)),
                );
              },
            );
          },
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              LoadingShimmer(height: 96),
              SizedBox(height: 10),
              LoadingShimmer(height: 96),
              SizedBox(height: 10),
              LoadingShimmer(height: 96),
            ],
          ),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 80),
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load your requests',
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '$e',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SentRequestTile extends StatelessWidget {
  const SentRequestTile({super.key, required this.request, this.onTap});

  final ServiceRequest request;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _statusVisuals(request.status);
    final dateLabel = _formatScheduled(
      request.scheduledServiceDate,
      request.timeSlot,
    );

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
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
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
                  Icon(
                    Icons.engineering_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.description.trim().isEmpty
                          ? 'Service request'
                          : request.description.trim(),
                      style: AppTypography.titleLarge.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusPill(label: statusLabel, color: statusColor),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      dateLabel,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.place_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.serviceAddress,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color) _statusVisuals(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.posted:
        return ('Posted', AppColors.primary);
      case ServiceRequestStatus.workerAccepted:
        return ('Interested', AppColors.primary);
      case ServiceRequestStatus.bidReceived:
        return ('Bid received', AppColors.accent);
      case ServiceRequestStatus.bidAccepted:
        return ('Bid accepted', AppColors.accent);
      case ServiceRequestStatus.onTheWay:
        return ('On the way', AppColors.accent);
      case ServiceRequestStatus.arrived:
        return ('Arrived', AppColors.accent);
      case ServiceRequestStatus.inProgress:
        return ('In progress', AppColors.accent);
      case ServiceRequestStatus.completed:
        return ('Completed', AppColors.success);
      case ServiceRequestStatus.cancelled:
        return ('Cancelled', AppColors.textMuted);
      case ServiceRequestStatus.unknown:
        return ('Unknown', AppColors.textMuted);
    }
  }

  String _formatScheduled(String dateYmd, ServiceRequestTimeSlot slot) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    String pretty = dateYmd;
    final parts = dateYmd.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null && m >= 1 && m <= 12) {
        pretty = '$d ${months[m - 1]} $y';
      }
    }
    final slotLabel = (slot.startTime.isEmpty && slot.endTime.isEmpty)
        ? ''
        : ' · ${slot.startTime}–${slot.endTime}';
    return '$pretty$slotLabel';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
