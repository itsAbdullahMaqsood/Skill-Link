import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/sent_bid.dart';
import 'package:skilllink/models/skill_post.dart';
import 'package:skilllink/Pages/bidding/bid_screen.dart';
import 'package:skilllink/Pages/offers/sent_bid_detail_screen.dart';
import 'package:skilllink/Pages/ongoing/ongoing_screen.dart';
import 'package:skilllink/Pages/post_detail/accept_offer_dialog.dart';
import 'package:skilllink/Pages/post_detail/post_detail_screen.dart';
import 'package:skilllink/Pages/profile/user_profile_detail_screen.dart';
import 'package:skilllink/Widgets/user_avatar.dart';
import 'package:skilllink/services/skill_post_service.dart';

class RecommendationCard extends StatelessWidget {
  final SkillPost post;
  final VoidCallback? onBalanceUpdate;
  final bool showActions;
  final VoidCallback? onTap;
  final void Function(String postId, bool hasUserBid)? onBidStatusChanged;
  final void Function(String postId)? onPostAccepted;

  const RecommendationCard({
    super.key,
    required this.post,
    this.onBalanceUpdate,
    this.showActions = true,
    this.onTap,
    this.onBidStatusChanged,
    this.onPostAccepted,
  });

  bool get _isOfferSkill => post.offerType.toUpperCase() == 'SKILL';
  bool get _isRequestSkill => post.requestType.toUpperCase() == 'SKILL';
  bool get _isSkillExchange => _isOfferSkill && _isRequestSkill;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(
                    post: post,
                    onBalanceUpdate: onBalanceUpdate,
                    onBidStatusChanged: onBidStatusChanged,
                    onPostAccepted: onPostAccepted,
                  ),
                ),
              );
            },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 14),
              _buildTitleDescription(),
              const SizedBox(height: 14),
              _buildOffersSection(),
              const SizedBox(height: 12),
              _buildNeedsSection(),
              if (showActions) ...[
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openUserProfileDetail(context, post.creatorUserId),
          child: UserAvatar(
            imageRef: post.profileImage,
            radius: 28,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      post.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (post.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 18),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (post.rating > 0) ...[
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      post.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _timeAgo(post.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildExchangeBadge(),
            if (post.matchesMySkills) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Match',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTitleDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.title.isNotEmpty)
          Text(
            post.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        if (post.title.isNotEmpty && post.description.isNotEmpty)
          const SizedBox(height: 4),
        if (post.description.isNotEmpty)
          Text(
            post.description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildOffersSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_upward, size: 16, color: Colors.green.shade700),
              const SizedBox(width: 6),
              Text(
                'OFFERS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isOfferSkill)
            _buildSkillContent(
              skills: post.offers,
              durationMinutes: post.courseTotalMinutes,
              courseOutline: post.courseOutline,
              color: Colors.green.shade700,
            )
          else
            _buildTimecoinContent(
              timeCoins: post.offerTimeCoins,
              color: Colors.green.shade700,
            ),
        ],
      ),
    );
  }

  Widget _buildNeedsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.purple.shade700),
              const SizedBox(width: 6),
              Text(
                'NEEDS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isRequestSkill)
            _buildSkillContent(
              skills: post.needs,
              durationMinutes: post.desiredDurationMinutes,
              color: Colors.purple.shade700,
            )
          else
            _buildTimecoinContent(
              timeCoins: post.requestTimeCoins,
              color: Colors.purple.shade700,
            ),
        ],
      ),
    );
  }

  Widget _buildSkillContent({
    required List<String> skills,
    int? durationMinutes,
    String? courseOutline,
    required Color color,
  }) {
    if (skills.isEmpty && durationMinutes == null) {
      return Text(
        'No skills specified',
        style: TextStyle(fontSize: 12, color: color),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (skills.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: TextStyle(fontSize: 12, color: color),
                ),
              );
            }).toList(),
          ),
        if (durationMinutes != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                _formatDuration(durationMinutes),
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTimecoinContent({int? timeCoins, required Color color}) {
    if (timeCoins == null) {
      return Text(
        'TimeCoins amount not set',
        style: TextStyle(fontSize: 12, color: color),
      );
    }
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade200, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: SvgPicture.asset(
                  'assets/images/timecoin.svg',
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) => Container(
                    width: 16,
                    height: 16,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$timeCoins',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'TimeCoins',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeBadge() {
    final isSkill = _isSkillExchange;
    final badgeColor = isSkill ? Colors.green : Colors.blue;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: badgeColor.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSkill ? Icons.swap_horiz : Icons.monetization_on,
                size: 14,
                color: badgeColor.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                isSkill ? 'Skill Exchange' : 'TimeCoin Exchange',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badgeColor.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _viewMyBid(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final bidJson = await SkillPostService().getBidByPostId(postId: post.id);
      if (!context.mounted) return;
      Navigator.pop(context);
      if (bidJson == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No bid found on this post')),
        );
        return;
      }
      final sentBid = SentBid.fromPostAndBidJson(post, bidJson);
      final cancelled = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => SentBidDetailScreen(bid: sentBid)),
      );
      if (cancelled == true) {
        onBidStatusChanged?.call(post.id, false);
      }
    } on ApiException catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load bid details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    if (post.hasUserBid!) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _viewMyBid(context),
          icon: const Icon(Icons.visibility_outlined, size: 18),
          label: const Text(
            'View Your Bid',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.teal.shade700,
            side: BorderSide(color: Colors.teal.shade300),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _handleAcceptPressed(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green.shade700,
              side: BorderSide(color: Colors.green.shade300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 18),
                SizedBox(width: 6),
                Text('Accept', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final placed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => BidScreen(post: post)),
              );
              if (placed == true) {
                onBidStatusChanged?.call(post.id, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gavel, size: 18),
                SizedBox(width: 6),
                Text('Bid', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAcceptPressed(BuildContext context) async {
    final accepted = await showAcceptOfferDialog(
      context,
      postId: post.id,
      posterName: post.name,
    );
    if (accepted != true || !context.mounted) return;

    onPostAccepted?.call(post.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post accepted — moved to Ongoing'),
        backgroundColor: Colors.green.shade700,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OngoingScreen()),
            );
          },
        ),
      ),
    );
  }

  static String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays >= 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  static String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }
}
