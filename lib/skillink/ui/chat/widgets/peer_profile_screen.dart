import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';

/// Args passed via `GoRouter.push(extra: ...)` into [PeerProfileScreen].
class PeerProfileArgs {
  const PeerProfileArgs({
    required this.peerId,
    required this.peerName,
    this.peerAvatar,
    required this.peerRole,
    this.peerEmail,
    this.peerPhone,
  });

  final String peerId;
  final String peerName;
  final String? peerAvatar;
  final UserRole peerRole;
  final String? peerEmail;
  final String? peerPhone;
}

/// Read-only profile view used when tapping the peer header in a chat
/// thread. Intentionally renders no "Message" or "View profile" CTAs to
/// avoid looping the user back into the chat they came from.
class PeerProfileScreen extends StatelessWidget {
  const PeerProfileScreen({super.key, required this.args});

  final PeerProfileArgs args;

  @override
  Widget build(BuildContext context) {
    final roleLabel = switch (args.peerRole) {
      UserRole.worker => 'Worker',
      UserRole.homeowner => 'Homeowner',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(args.peerName, style: AppTypography.headlineMedium),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Center(
              child: _PeerAvatar(name: args.peerName, url: args.peerAvatar),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    args.peerName.isEmpty ? 'SkillLink user' : args.peerName,
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (args.peerRole == UserRole.worker) ...[
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          roleLabel,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if ((args.peerEmail ?? '').isNotEmpty ||
                (args.peerPhone ?? '').isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if ((args.peerEmail ?? '').isNotEmpty)
                      _InfoLine(
                        icon: Icons.mail_outline,
                        label: 'Email',
                        value: args.peerEmail!,
                      ),
                    if ((args.peerPhone ?? '').isNotEmpty)
                      _InfoLine(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: args.peerPhone!,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PeerAvatar extends StatelessWidget {
  const _PeerAvatar({required this.name, this.url});

  final String name;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final fallback = CircleAvatar(
      radius: 56,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        initial,
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 36,
        ),
      ),
    );
    final resolved = resolveActiveBackendMediaUrl(url);
    if (resolved == null) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: resolved,
        width: 112,
        height: 112,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
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
