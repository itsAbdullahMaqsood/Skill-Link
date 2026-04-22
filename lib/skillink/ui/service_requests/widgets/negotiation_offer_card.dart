import 'package:flutter/material.dart';
import 'package:skilllink/skillink/domain/logic/service_request_actions.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class NegotiationOfferCard extends StatelessWidget {
  const NegotiationOfferCard({
    super.key,
    required this.offer,
    required this.viewer,
    required this.isLatest,
    required this.showAcceptHint,
    this.onAccept,
    this.onCounter,
    this.onReject,
    this.submitting = false,
  });

  final NegotiationOffer offer;
  final ServiceRequestViewer viewer;
  final bool isLatest;

  final bool showAcceptHint;

  final VoidCallback? onAccept;
  final VoidCallback? onCounter;
  final VoidCallback? onReject;

  final bool submitting;

  @override
  Widget build(BuildContext context) {
    final fromWorker = offer.actorRole == NegotiationActor.worker;
    final accent =
        fromWorker ? AppColors.primary : AppColors.accent;
    final actorLabel = _actorLabel(viewer, offer.actorRole);
    final hasActionRow =
        onAccept != null || onCounter != null || onReject != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatest
              ? accent.withValues(alpha: 0.45)
              : AppColors.border,
          width: isLatest ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ActorPill(role: offer.actorRole, label: actorLabel),
              const Spacer(),
              Text(
                '#${offer.sequence}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${offer.currency} ${_formatAmount(offer.amount)}',
                style: AppTypography.titleLarge.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _formatDateTime(offer.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          if (showAcceptHint) ...[
            const SizedBox(height: 10),
            const _AcceptedHint(),
          ],
          if (hasActionRow) ...[
            const SizedBox(height: 14),
            _ActionRow(
              onAccept: onAccept,
              onCounter: onCounter,
              onReject: onReject,
              submitting: submitting,
            ),
          ],
        ],
      ),
    );
  }

  static String _actorLabel(
    ServiceRequestViewer viewer,
    NegotiationActor role,
  ) {
    final mine = (viewer == ServiceRequestViewer.worker &&
            role == NegotiationActor.worker) ||
        (viewer == ServiceRequestViewer.customer &&
            role == NegotiationActor.customer);
    if (mine) return 'Your offer';
    switch (role) {
      case NegotiationActor.worker:
        return 'Worker bid';
      case NegotiationActor.customer:
        return 'Customer offer';
      case NegotiationActor.unknown:
        return 'Offer';
    }
  }
}

class _ActorPill extends StatelessWidget {
  const _ActorPill({required this.role, required this.label});
  final NegotiationActor role;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = role == NegotiationActor.worker
        ? AppColors.primary
        : AppColors.accent;
    final icon = role == NegotiationActor.worker
        ? Icons.handyman_outlined
        : Icons.person_outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcceptedHint extends StatelessWidget {
  const _AcceptedHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_outlined,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Worker accepted your offer. Tap Accept to finalise.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onAccept,
    required this.onCounter,
    required this.onReject,
    required this.submitting,
  });
  final VoidCallback? onAccept;
  final VoidCallback? onCounter;
  final VoidCallback? onReject;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (onAccept != null) {
      children.add(
        Expanded(
          child: FilledButton.icon(
            onPressed: submitting ? null : onAccept,
            icon: submitting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 16),
            label: const Text(
              'Accept',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    }
    if (onCounter != null) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 8));
      children.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: submitting ? null : onCounter,
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: const Text(
              'Counter',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.6)),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    }
    if (onReject != null) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 8));
      children.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: submitting ? null : onReject,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text(
              'Reject',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    }
    return Row(children: children);
  }
}

String _formatAmount(num n) {
  if (n == n.truncate()) return n.toInt().toString();
  return n.toString();
}

String _formatDateTime(DateTime? d) {
  if (d == null) return '';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${months[d.month - 1]} · $hh:$mm';
}
