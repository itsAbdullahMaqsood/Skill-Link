import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/chat/chat_entry.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';

class PartyCard extends ConsumerWidget {
  const PartyCard({
    super.key,
    required this.party,
    required this.variant,
  });

  final ServiceRequestParty party;
  final PartyCardVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = _titleFor(variant);
    final resolvedAvatar = _resolveAvatar(party.profilePic);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundAvatar(url: resolvedAvatar, radius: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      party.fullName.isEmpty ? 'Unnamed' : party.fullName,
                      style: AppTypography.titleLarge.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _MetaRow(party: party),
                  ],
                ),
              ),
            ],
          ),
          if (party.services.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ServicesWrap(services: party.services),
          ],
          if (party.phoneNumber.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  party.phoneNumber,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openProfile(context),
                  icon: const Icon(Icons.person_outline, size: 18),
                  label: const Text(
                    'View profile',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openChat(context, ref),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Chat',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openProfile(BuildContext context) {
    if (variant == PartyCardVariant.worker) {
      context.push(Routes.workerProfile(party.id, hideBook: true));
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: AppColors.background,
        builder: (_) => _CustomerDetailSheet(party: party),
      );
    }
  }

  Future<void> _openChat(BuildContext context, WidgetRef ref) {
    final resolved = _resolveAvatar(party.profilePic);
    return ChatEntry.openWithPeer(
      context,
      ref,
      peerId: party.id,
      peerName: party.fullName.isEmpty ? 'SkillLink user' : party.fullName,
      peerAvatar: resolved,
      peerRole: variant == PartyCardVariant.worker
          ? UserRole.worker
          : UserRole.homeowner,
    );
  }

  String _titleFor(PartyCardVariant v) => switch (v) {
        PartyCardVariant.worker => 'WORKER',
        PartyCardVariant.customer => 'CUSTOMER',
      };
}

enum PartyCardVariant { worker, customer }

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.party});
  final ServiceRequestParty party;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (party.ratings > 0 || party.reviews > 0) {
      rows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF2B84B)),
            const SizedBox(width: 2),
            Text(
              party.ratings.toStringAsFixed(1),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${party.reviews})',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }
    if (party.email.isNotEmpty) {
      rows.add(
        Text(
          party.email,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: rows,
    );
  }
}

class _ServicesWrap extends StatelessWidget {
  const _ServicesWrap({required this.services});
  final List<ServiceRequestPartyService> services;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final s in services)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              s.name,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _CustomerDetailSheet extends StatelessWidget {
  const _CustomerDetailSheet({required this.party});
  final ServiceRequestParty party;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
            Row(
              children: [
                RoundAvatar(
                  url: _resolveAvatar(party.profilePic),
                  radius: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        party.fullName.isEmpty ? 'Customer' : party.fullName,
                        style: AppTypography.titleLarge,
                      ),
                      if (party.email.isNotEmpty)
                        Text(
                          party.email,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (party.phoneNumber.isNotEmpty)
              _InfoLine(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: party.phoneNumber,
              ),
            if (party.email.isNotEmpty)
              _InfoLine(
                icon: Icons.mail_outline,
                label: 'Email',
                value: party.email,
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTypography.bodyMedium),
          ),
        ],
      ),
    );
  }
}

String? _resolveAvatar(String? path) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = AppConstants.apiBaseUrl;
  final trimmedBase =
      base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  final suffix = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$trimmedBase$suffix';
}
