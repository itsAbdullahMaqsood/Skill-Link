import 'package:flutter/material.dart';
import 'package:skilllink/models/user.dart';
import 'package:skilllink/Widgets/user_avatar.dart';
import 'package:skilllink/Pages/login/login_page.dart';
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/services/signup_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            UserAvatar(
              imageRef: user.profilePic,
              radius: 48,
              backgroundColor: Colors.grey.shade200,
            ),
            if (user.isVerified)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.verified,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (user.isPremium) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber.shade800),
                    const SizedBox(width: 4),
                    Text(
                      'Premium',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ProfileStatsRow extends StatelessWidget {
  final UserModel user;

  const ProfileStatsRow({super.key, required this.user});

  Widget _stat(
    BuildContext context,
    IconData icon,
    String label,
    dynamic value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
        _stat(
          context,
          Icons.monetization_on_outlined,
          'TimeCoins',
          user.timeCoins,
        ),
        const SizedBox(width: 12),
        _stat(
          context,
          Icons.star_outline,
          'Rating',
          user.ratings.toStringAsFixed(1),
        ),
        const SizedBox(width: 12),
        _stat(
          context,
          Icons.rate_review_outlined,
          'Reviews',
          user.reviewsCount,
        ),
      ],
    );
  }
}

class ProfileInfoSection extends StatelessWidget {
  final UserModel user;

  const ProfileInfoSection({super.key, required this.user});

  Widget _tile(IconData icon, String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
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
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasContact =
        user.email.isNotEmpty ||
        user.phoneNumber.isNotEmpty ||
        user.location.isNotEmpty;
    if (!hasContact) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Contact',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.email.isNotEmpty)
            _tile(Icons.email_outlined, 'Email', user.email),
          if (user.phoneNumber.isNotEmpty)
            _tile(Icons.phone_outlined, 'Phone', user.phoneNumber),
          if (user.location.isNotEmpty)
            _tile(Icons.location_on_outlined, 'Location', user.location),
          if (user.age > 0)
            _tile(Icons.cake_outlined, 'Age', user.age.toString()),
          if (user.gender.isNotEmpty)
            _tile(Icons.person_outline, 'Gender', user.gender),
        ],
      ),
    );
  }
}

class ProfileProfessionalSection extends StatefulWidget {
  final UserModel user;

  final bool combineSkillLists;

  final String? combinedSkillsTitle;

  const ProfileProfessionalSection({
    super.key,
    required this.user,
    this.combineSkillLists = false,
    this.combinedSkillsTitle,
  });

  @override
  State<ProfileProfessionalSection> createState() =>
      _ProfileProfessionalSectionState();
}

class _ProfileProfessionalSectionState
    extends State<ProfileProfessionalSection> {
  Map<String, String> _skillNamesById = {};
  bool _skillsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      final list = await SignupApiService().getSkills();
      if (!mounted) return;
      setState(() {
        _skillNamesById = {for (final s in list) s.id: s.name};
        _skillsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _skillNamesById = {};
        _skillsLoading = false;
      });
    }
  }

  List<String> _resolveNames(List<String> ids) {
    return ids
        .map((id) => _skillNamesById[id] ?? id)
        .where((n) => n.isNotEmpty)
        .toList();
  }

  List<String> _mergedSkillIds(UserModel user) {
    final seen = <String>{};
    final out = <String>[];
    for (final id in [...user.offeringSkills, ...user.learningSkills]) {
      if (seen.add(id)) out.add(id);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final hasEducation = user.education != null && user.education!.isNotEmpty;
    final hasExperience =
        user.pastExperience != null && user.pastExperience!.isNotEmpty;
    final hasOffering = user.offeringSkills.isNotEmpty;
    final hasLearning = user.learningSkills.isNotEmpty;
    final mergedIds = widget.combineSkillLists ? _mergedSkillIds(user) : <String>[];
    final hasMerged = mergedIds.isNotEmpty;
    final combinedTitle = widget.combinedSkillsTitle;

    if (widget.combineSkillLists && combinedTitle != null) {
      final hasAny = hasEducation || hasExperience || hasMerged;
      if (!hasAny) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasEducation || hasExperience)
            _SectionCard(
              title: 'Professional',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasEducation) _eduRow(user.education!),
                  if (hasExperience) _expRow(user.pastExperience!),
                ],
              ),
            ),
          if ((hasEducation || hasExperience) && hasMerged) const SizedBox(height: 16),
          if (hasMerged)
            _SectionCard(
              title: combinedTitle,
              child: _skillsWrap(
                _resolveNames(mergedIds),
                Colors.deepOrange.shade50,
                Colors.deepOrange.shade900,
              ),
            ),
        ],
      );
    }

    final hasAny = hasEducation || hasExperience || hasOffering || hasLearning;
    if (!hasAny) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasEducation || hasExperience)
          _SectionCard(
            title: 'Professional',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasEducation) _eduRow(user.education!),
                if (hasExperience) _expRow(user.pastExperience!),
              ],
            ),
          ),
        if (hasEducation || hasExperience) const SizedBox(height: 16),
        if (hasOffering)
          _SectionCard(
            title: 'Offering Skills',
            child: _skillsWrap(
              _resolveNames(user.offeringSkills),
              Colors.green.shade100,
              Colors.green.shade800,
            ),
          ),
        if (hasOffering) const SizedBox(height: 16),
        if (hasLearning)
          _SectionCard(
            title: 'Learning Skills',
            child: _skillsWrap(
              _resolveNames(user.learningSkills),
              Colors.blue.shade100,
              Colors.blue.shade800,
            ),
          ),
      ],
    );
  }

  Widget _eduRow(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.school_outlined, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Education',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _expRow(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.work_outline, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Experience',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _skillsWrap(List<String> names, Color chipBg, Color chipFg) {
    if (_skillsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (names.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          'No skills listed',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: names
          .map(
            (name) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: chipFg,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class ProfileLinksSection extends StatelessWidget {
  final UserModel user;

  const ProfileLinksSection({super.key, required this.user});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid URL')),
        );
      }
      return;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
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

  Widget _linkTile(
    BuildContext context,
    IconData icon,
    String label,
    String url,
  ) {
    if (url.isEmpty) return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchUrl(context, url),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.open_in_new, size: 18, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPortfolio = user.portfolioFileUrl.isNotEmpty;
    final hasResume = user.resumeFileUrl.isNotEmpty;
    final hasCerts = user.earnedCertificates.isNotEmpty;
    if (!hasPortfolio && !hasResume && !hasCerts) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: 'Documents',
      child: Column(
        children: [
          if (hasPortfolio)
            _linkTile(
              context,
              Icons.folder_open_outlined,
              'Portfolio',
              user.portfolioFileUrl,
            ),
          if (hasResume)
            _linkTile(context, Icons.description_outlined, 'Resume', user.resumeFileUrl),
          if (hasCerts) ...[
            for (var i = 0; i < user.earnedCertificateUrls.length; i++)
              _linkTile(
                context,
                Icons.workspace_premium_outlined,
                'Certificate ${i + 1}',
                user.earnedCertificateUrls[i],
              ),
          ],
        ],
      ),
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
            color: Colors.black.withValues(alpha: 0.03),
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

class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onEditProfile;

  const ProfileActionButtons({super.key, required this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onEditProfile,
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade400),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () async {
            await AuthService().logout();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          child: Text(
            'Logout',
            style: TextStyle(
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
