import 'package:flutter/material.dart';
import 'package:skilllink/skillink/domain/models/job.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/job_status_chip.dart';
import 'package:skilllink/skillink/utils/text_format.dart';

class IncomingCard extends StatelessWidget {
  const IncomingCard({
    super.key,
    required this.job,
    required this.onAcceptAsIs,
    required this.onBid,
    required this.onReject,
  });

  final Job job;

  final VoidCallback onAcceptAsIs;

  final VoidCallback onBid;

  final ValueChanged<String?> onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _iconFor(job.serviceType),
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
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
          Text(
            job.description,
            style: AppTypography.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${job.address.area}, ${job.address.city}',
                  style: AppTypography.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.schedule_rounded,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                _timeLabel(job.scheduledDate),
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                job.paymentMethod.name == 'cash'
                    ? 'Cash on completion'
                    : 'In-app payment',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textMuted),
              ),
              const Spacer(),
              if (job.finalPrice != null)
                Text(
                  'PKR ${job.finalPrice!.toStringAsFixed(0)}',
                  style: AppTypography.titleLarge
                      .copyWith(color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAcceptAsIs,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    'Accept As-Is',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onBid,
                  icon: const Icon(Icons.gavel, size: 18),
                  label: const Text(
                    'Bid',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openRejectSheet(context),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text(
                'Reject',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRejectSheet(BuildContext context) async {
    final result = await showModalBottomSheet<_RejectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RejectReasonSheet(),
    );
    if (result?.confirmed == true) {
      onReject(result!.reason);
    }
  }

  static String _timeLabel(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'ASAP';
    if (diff.inMinutes < 60) return 'In ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'In ${diff.inHours}h';
    return 'In ${diff.inDays}d';
  }
}

class _RejectResult {
  const _RejectResult({required this.confirmed, this.reason});
  final bool confirmed;
  final String? reason;
}

class _RejectReasonSheet extends StatefulWidget {
  const _RejectReasonSheet();

  @override
  State<_RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<_RejectReasonSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Reject request', style: AppTypography.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Tell the homeowner why (optional). This helps our matching '
            'engine send you better-fit jobs next time.',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'e.g. Too far from me, schedule doesn\'t work…',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context)
                      .pop(const _RejectResult(confirmed: false)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final text = _controller.text.trim();
                    Navigator.of(context).pop(_RejectResult(
                      confirmed: true,
                      reason: text.isEmpty ? null : text,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reject request',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(String type) => switch (type.toLowerCase()) {
      'electrician' || 'electrical' => Icons.electrical_services_rounded,
      'plumber' || 'plumbing' => Icons.plumbing_rounded,
      'hvac' || 'ac' => Icons.ac_unit_rounded,
      'carpenter' || 'carpentry' => Icons.carpenter_rounded,
      _ => Icons.handyman_rounded,
    };
