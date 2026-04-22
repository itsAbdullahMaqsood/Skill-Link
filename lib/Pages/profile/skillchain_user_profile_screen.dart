import 'package:flutter/material.dart';
import 'package:skilllink/models/user.dart';
import 'package:skilllink/Widgets/profile_widgets.dart';
import 'package:skilllink/Widgets/user_avatar.dart';
import 'package:skilllink/Pages/profile/edit_profile_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SkillchainUserProfileLayout extends StatelessWidget {
  final UserModel user;
  final bool isLabourSession;
  final bool isOwnProfile;
  final bool showLabourCnicSection;
  final ValueChanged<UserModel>? onProfileUpdated;
  final Widget? belowStatsActions;

  const SkillchainUserProfileLayout({
    super.key,
    required this.user,
    required this.isLabourSession,
    required this.isOwnProfile,
    this.showLabourCnicSection = true,
    this.onProfileUpdated,
    this.belowStatsActions,
  });

  static String _roleTitle(UserModel u, bool labour) {
    if (!labour) return 'Digital skills';
    if (u.isLabourWorkerRole) return 'Service professional';
    return 'Service seeker';
  }

  static List<Color> _heroGradient(UserModel u, bool labour) {
    if (!labour) {
      return const [Color(0xFF1E3A5F), Color(0xFF2563EB)];
    }
    if (u.isLabourWorkerRole) {
      return const [Color(0xFF7C2D12), Color(0xFFEA580C)];
    }
    return const [Color(0xFF334155), Color(0xFF64748B)];
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _heroGradient(user, isLabourSession);
    final roleTitle = _roleTitle(user, isLabourSession);
    final subtitle = user.location.trim().isNotEmpty
        ? user.location.trim()
        : (user.email.isNotEmpty ? user.email : 'Member');

    final mergeSkills = isLabourSession;
    final combinedTitle = user.isLabourWorkerRole
        ? 'Services I offer'
        : "Services I'm interested in";

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHero(
            user: user,
            gradientColors: gradientColors,
            roleTitle: roleTitle,
            subtitle: subtitle,
          ),
          Transform.translate(
            offset: const Offset(0, -22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _StatStrip(user: user),
            ),
          ),
          if (belowStatsActions != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: belowStatsActions!,
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileInfoSection(user: user),
                if (isLabourSession && showLabourCnicSection) ...[
                  const SizedBox(height: 16),
                  _LabourCnicSection(user: user),
                ],
                const SizedBox(height: 16),
                ProfileProfessionalSection(
                  user: user,
                  combineSkillLists: mergeSkills,
                  combinedSkillsTitle: mergeSkills ? combinedTitle : null,
                ),
                const SizedBox(height: 16),
                ProfileLinksSection(user: user),
                if (isOwnProfile) ...[
                  const SizedBox(height: 24),
                  ProfileActionButtons(
                    onEditProfile: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => EditProfilePage(
                            user: user,
                            onProfileUpdated:
                                onProfileUpdated ?? (UserModel _) {},
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final UserModel user;
  final List<Color> gradientColors;
  final String roleTitle;
  final String subtitle;

  const _ProfileHero({
    required this.user,
    required this.gradientColors,
    required this.roleTitle,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: UserAvatar(
                      imageRef: user.profilePic,
                      radius: 52,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  if (user.isVerified)
                    Positioned(
                      right: -2,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.verified_rounded,
                          color: Colors.blue.shade600,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                user.fullName.isNotEmpty ? user.fullName : 'Member',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeroChip(
                    icon: Icons.badge_outlined,
                    label: roleTitle,
                    foreground: gradientColors.first,
                  ),
                  if (user.isPremium)
                    _HeroChip(
                      icon: Icons.star_rounded,
                      label: 'Premium',
                      foreground: Colors.amber.shade900,
                      background: Colors.amber.shade100,
                    ),
                ],
              ),
              if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    user.bio!.trim(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color? background;

  const _HeroChip({
    required this.icon,
    required this.label,
    required this.foreground,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatStrip extends StatelessWidget {
  final UserModel user;

  const _StatStrip({required this.user});

  Widget _tile({
    required IconData icon,
    required String value,
    required String label,
    required Color accent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: accent),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tile(
          icon: Icons.toll_outlined,
          value: user.timeCoins.toString(),
          label: 'TimeCoins',
          accent: const Color(0xFF2563EB),
        ),
        const SizedBox(width: 10),
        _tile(
          icon: Icons.star_rate_rounded,
          value: user.ratings.toStringAsFixed(1),
          label: 'Rating',
          accent: Colors.amber.shade800,
        ),
        const SizedBox(width: 10),
        _tile(
          icon: Icons.reviews_outlined,
          value: user.reviewsCount.toString(),
          label: 'Reviews',
          accent: const Color(0xFF059669),
        ),
      ],
    );
  }
}

class _LabourCnicSection extends StatelessWidget {
  final UserModel user;

  const _LabourCnicSection({required this.user});

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid link')),
      );
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final front = user.cnicFrontUrl;
    final back = user.cnicBackUrl;
    if (front.isEmpty && back.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Identity (CNIC)',
      child: Column(
        children: [
          _cnicRow(
            context,
            label: 'Front',
            available: front.isNotEmpty,
            onOpen: front.isNotEmpty ? () => _open(context, front) : null,
          ),
          Divider(height: 20, color: Colors.grey.shade200),
          _cnicRow(
            context,
            label: 'Back',
            available: back.isNotEmpty,
            onOpen: back.isNotEmpty ? () => _open(context, back) : null,
          ),
        ],
      ),
    );
  }

  Widget _cnicRow(
    BuildContext context, {
    required String label,
    required bool available,
    required VoidCallback? onOpen,
  }) {
    return Row(
      children: [
        Icon(
          Icons.credit_card_outlined,
          size: 22,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                available ? 'On file — tap to view' : 'Not uploaded',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: available ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        if (available && onOpen != null)
          FilledButton.tonal(
            onPressed: onOpen,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('Open'),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
