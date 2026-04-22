import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/sent_bid.dart';
import 'package:skilllink/models/skill_post.dart';
import 'package:skilllink/Pages/bidding/bid_screen.dart';
import 'package:skilllink/Pages/ongoing/ongoing_screen.dart';
import 'package:skilllink/Pages/post_detail/accept_offer_dialog.dart';
import 'package:skilllink/Pages/profile/user_profile_detail_screen.dart';
import 'package:skilllink/Widgets/user_avatar.dart';
import 'package:skilllink/Pages/offers/sent_bid_detail_screen.dart';
import 'package:skilllink/services/skill_post_service.dart';

class PostDetailScreen extends StatefulWidget {
  final SkillPost post;
  final VoidCallback? onBalanceUpdate;
  final void Function(String postId, bool hasUserBid)? onBidStatusChanged;
  final void Function(String postId)? onPostAccepted;

  const PostDetailScreen({
    super.key,
    required this.post,
    this.onBalanceUpdate,
    this.onBidStatusChanged,
    this.onPostAccepted,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late bool _hasUserBid;
  bool _isCancellingBid = false;

  SkillPost get post => widget.post;

  @override
  void initState() {
    super.initState();
    _hasUserBid = post.hasUserBid!;
  }

  bool get _isOfferSkill => post.offerType.toUpperCase() == 'SKILL';
  bool get _isRequestSkill => post.requestType.toUpperCase() == 'SKILL';
  bool get _isSkillExchange => _isOfferSkill && _isRequestSkill;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCreatorHeader(),
                  const SizedBox(height: 20),
                  _buildTitleSection(),
                  const SizedBox(height: 20),
                  _buildOffersSection(),
                  const SizedBox(height: 12),
                  _buildNeedsSection(),
                  if (post.courseOutline != null &&
                      post.courseOutline!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildCourseOutline(),
                  ],
                  const SizedBox(height: 20),
                  _buildMetadata(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildCreatorHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
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
          const SizedBox(width: 14),
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
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (post.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: Colors.blue, size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                if (post.rating > 0)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        post.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
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
      ),
    );
  }

  Widget _buildExchangeBadge() {
    final isSkill = _isSkillExchange;
    final badgeColor = isSkill ? Colors.green : Colors.blue;
    return Container(
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
    );
  }

  Widget _buildTitleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.title.isNotEmpty)
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          if (post.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              post.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOffersSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isOfferSkill)
            _buildSkillContent(
              skills: post.offers,
              durationMinutes: post.courseTotalMinutes,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(14),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
    required Color color,
  }) {
    if (skills.isEmpty && durationMinutes == null) {
      return Text(
        'No skills specified',
        style: TextStyle(fontSize: 13, color: color),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (skills.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map(
                  (skill) => Container(
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
                      style: TextStyle(fontSize: 13, color: color),
                    ),
                  ),
                )
                .toList(),
          ),
        if (durationMinutes != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                _formatDuration(durationMinutes),
                style: TextStyle(fontSize: 13, color: color),
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
        style: TextStyle(fontSize: 13, color: color),
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
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$timeCoins',
                style: TextStyle(
                  fontSize: 13,
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

  Widget _buildCourseOutline() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 16,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Course Outline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.courseOutline!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        children: [
          if (post.createdAt != null)
            _metaChip(
              icon: Icons.access_time,
              text: 'Posted ${_timeAgo(post.createdAt)}',
            ),
          if (post.expiryDate != null)
            _metaChip(
              icon: Icons.hourglass_bottom,
              text: post.isExpired
                  ? 'Expired'
                  : 'Expires ${_timeUntil(post.expiryDate!)}',
              isWarning:
                  post.isExpired ||
                  post.expiryDate!.isBefore(
                    DateTime.now().add(const Duration(days: 3)),
                  ),
            ),
          _metaChip(
            icon: Icons.circle,
            text:
                post.postStatus[0].toUpperCase() + post.postStatus.substring(1),
          ),
        ],
      ),
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String text,
    bool isWarning = false,
  }) {
    final color = isWarning ? Colors.red : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color.shade600),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _hasUserBid
          ? _buildBidPlacedActions(context)
          : _buildDefaultActions(context),
    );
  }

  Future<void> _handleCancelBid() async {
    setState(() => _isCancellingBid = true);
    try {
      final result = await SkillPostService().cancelBid(postId: post.id);
      if (!mounted) return;
      final msg = (result['message'] as String?) ?? 'Bid cancelled';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green),
      );
      setState(() => _hasUserBid = false);
      widget.onBidStatusChanged?.call(post.id, false);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCancellingBid = false);
    }
  }

  Future<void> _viewMyBid() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final bidJson =
          await SkillPostService().getBidByPostId(postId: post.id);
      if (!mounted) return;
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
      if (cancelled == true && mounted) {
        setState(() => _hasUserBid = false);
        widget.onBidStatusChanged?.call(post.id, false);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load bid details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBidPlacedActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _viewMyBid,
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text(
              'View Your Bid',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal.shade700,
              side: BorderSide(color: Colors.teal.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isCancellingBid ? null : _handleCancelBid,
            icon: _isCancellingBid
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cancel_outlined, size: 18),
            label: Text(
              _isCancellingBid ? 'Cancelling...' : 'Cancel Bid',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleAccept(context),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text(
              'Accept',
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
            onPressed: () async {
              final placed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => BidScreen(post: post)),
              );
              if (placed == true && mounted) {
                setState(() => _hasUserBid = true);
                widget.onBidStatusChanged?.call(post.id, true);
              }
            },
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
    );
  }

  Future<void> _handleAccept(BuildContext context) async {
    final accepted = await showAcceptOfferDialog(
      context,
      postId: post.id,
      posterName: post.name,
    );
    if (accepted != true || !context.mounted) return;

    widget.onPostAccepted?.call(post.id);

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

    Navigator.pop(context);
  }

  static String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays >= 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  static String _timeUntil(DateTime date) {
    final diff = date.difference(DateTime.now());
    if (diff.inDays >= 365) return 'in ${diff.inDays ~/ 365}y';
    if (diff.inDays >= 30) return 'in ${diff.inDays ~/ 30}mo';
    if (diff.inDays >= 1) return 'in ${diff.inDays}d';
    if (diff.inHours >= 1) return 'in ${diff.inHours}h';
    return 'soon';
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
