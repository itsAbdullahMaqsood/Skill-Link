import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/skill_post.dart';
import 'package:skilllink/models/post_bid.dart';
import 'package:skilllink/services/skill_post_service.dart';
import 'package:skilllink/Pages/offers/accept_bid_dialog.dart';
import 'package:skilllink/Pages/offers/bid_sections.dart';
import 'package:skilllink/Pages/ongoing/ongoing_screen.dart';
import 'package:skilllink/Pages/profile/user_profile_detail_screen.dart';
import 'package:skilllink/Widgets/user_avatar.dart';

class MyPostDetailScreen extends StatefulWidget {
  final SkillPost post;

  const MyPostDetailScreen({super.key, required this.post});

  @override
  State<MyPostDetailScreen> createState() => _MyPostDetailScreenState();
}

class _MyPostDetailScreenState extends State<MyPostDetailScreen> {
  final SkillPostService _service = SkillPostService();
  List<PostBid> _bids = [];
  bool _isLoadingBids = true;
  String? _bidError;
  String? _workingBidId;

  SkillPost get post => widget.post;

  bool get _isOfferSkill => post.offerType.toUpperCase() == 'SKILL';
  bool get _isRequestSkill => post.requestType.toUpperCase() == 'SKILL';
  bool get _isSkillExchange => _isOfferSkill && _isRequestSkill;

  @override
  void initState() {
    super.initState();
    _fetchBids();
  }

  Future<void> _fetchBids() async {
    setState(() {
      _isLoadingBids = true;
      _bidError = null;
    });
    try {
      final result = await _service.getPostById(post.id);
      setState(() {
        _bids = result.bids;
        _isLoadingBids = false;
      });
    } catch (e) {
      setState(() {
        _bidError = 'Could not load bids';
        _isLoadingBids = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Post'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBids,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPostCard(),
              const SizedBox(height: 24),
              _buildBidsHeader(),
              const SizedBox(height: 12),
              _buildBidsList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPostCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreatorRow(),
            const SizedBox(height: 16),
            if (post.title.isNotEmpty)
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            if (post.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                post.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildOffersSection(),
            const SizedBox(height: 10),
            _buildNeedsSection(),
            if (post.courseOutline != null &&
                post.courseOutline!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildCourseOutline(),
            ],
            const SizedBox(height: 16),
            _buildMetadata(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorRow() {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openUserProfileDetail(context, post.creatorUserId),
          child: UserAvatar(
            imageRef: post.profileImage,
            radius: 22,
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (post.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                ],
              ),
              if (post.createdAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _timeAgo(post.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildExchangeBadge(),
            const SizedBox(height: 6),
            _buildStatusBadge(post.postStatus),
          ],
        ),
      ],
    );
  }

  Widget _buildExchangeBadge() {
    final isSkill = _isSkillExchange;
    final badgeColor = isSkill ? Colors.green : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSkill ? Icons.swap_horiz : Icons.monetization_on,
            size: 13,
            color: badgeColor.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            isSkill ? 'Skill Exchange' : 'TimeCoin Exchange',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'active':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
      case 'expired':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
      case 'completed':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
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
              Icon(Icons.arrow_upward, size: 15, color: Colors.green.shade700),
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
              Icon(Icons.check_circle, size: 15, color: Colors.purple.shade700),
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
            children: skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                  ),
                )
                .toList(),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            fontSize: 13,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                'Course Outline',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post.courseOutline!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
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
          )
        else
          _metaChip(icon: Icons.hourglass_bottom, text: 'No expiry'),
      ],
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String text,
    bool isWarning = false,
  }) {
    final color = isWarning ? Colors.red : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBidsHeader() {
    final count = _isLoadingBids ? '' : ' (${_bids.length})';
    return Row(
      children: [
        Icon(Icons.gavel, size: 18, color: Colors.orange.shade700),
        const SizedBox(width: 8),
        Text(
          'Bids Received$count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildBidsList() {
    if (_isLoadingBids) {
      return _buildBidsLoading();
    }
    if (_bidError != null) {
      return _buildBidsError();
    }
    if (_bids.isEmpty) {
      return _buildBidsEmpty();
    }
    return Column(children: _bids.map((bid) => _buildBidCard(bid)).toList());
  }

  Widget _buildBidsLoading() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading bids...',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildBidsError() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            _bidError!,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _fetchBids,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBidsEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No bids yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bids from other users will appear here.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildBidCard(PostBid bid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBidHeader(bid),
          const Divider(height: 20),
          buildCounterSection(
            label: 'Counter Proposal',
            accentColor: Colors.orange.shade700,
            offerType: post.offerType,
            requestType: post.requestType,
            counterTimeCoins: bid.suggestedTimeCoins,
            counterBidderTeachingDuration: bid.bidderTeachingDuration,
            counterPosterTeachingDuration: bid.posterTeachingDuration,
          ),
          if (bid.message != null && bid.message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildBidMessage(bid.message!),
          ],
          const SizedBox(height: 12),
          _buildBidFooter(bid),
          const SizedBox(height: 14),
          _buildBidActions(bid),
        ],
      ),
    );
  }

  Widget _buildBidHeader(PostBid bid) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openUserProfileDetail(context, bid.bidderId),
          child: UserAvatar(
            imageRef: bid.bidderProfilePic,
            radius: 18,
            backgroundColor: Colors.orange.shade100,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bid.bidderName.isNotEmpty ? bid.bidderName : 'Unknown',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                bid.bidderEmail,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        _buildBidStatusChip(bid.status),
      ],
    );
  }

  Widget _buildBidStatusChip(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'accepted':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
      case 'rejected':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
      default:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _buildBidMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.message_outlined, size: 13, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidFooter(PostBid bid) {
    return Row(
      children: [
        if (bid.createdAt != null)
          _footerChip(
            icon: Icons.access_time,
            text: 'Bid ${_timeAgo(bid.createdAt)}',
          ),
        if (bid.acceptComment != null && bid.acceptComment!.isNotEmpty) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              bid.acceptComment!,
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBidActions(PostBid bid) {
    final isPending = bid.status.toLowerCase() == 'pending';
    if (!isPending) {
      return const SizedBox.shrink();
    }
    final isWorking = _workingBidId == bid.bidId;
    final disabled = _workingBidId != null;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: disabled ? null : () => _onAcceptBid(bid),
            icon: isWorking
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_circle_outline, size: 16),
            label: const Text(
              'Accept',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.green.shade300,
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: disabled ? null : () => _onRejectBid(bid),
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text(
              'Reject',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onAcceptBid(PostBid bid) async {
    if (bid.bidId.isEmpty) return;
    final accepted = await showAcceptBidDialog(
      context,
      postId: post.id,
      bidId: bid.bidId,
      bidderName: bid.bidderName,
    );
    if (accepted != true || !mounted) return;

    setState(() {
      _bids = _bids
          .map((b) => b.bidId == bid.bidId ? _withStatus(b, 'accepted') : b)
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bid accepted — added to Ongoing'),
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

  Future<void> _onRejectBid(PostBid bid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject bid?'),
        content: const Text(
          'The bidder will see that their bid was rejected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Dismiss'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _workingBidId = bid.bidId);
    try {
      if (bid.bidId.isNotEmpty) {
        await _service.rejectBid(postId: post.id, bidId: bid.bidId);
      }
    } on ApiException catch (e) {
      debugPrint('[MyPostDetail] rejectBid API failed: ${e.message}');
    } catch (e) {
      debugPrint('[MyPostDetail] rejectBid error: $e');
    }
    if (!mounted) return;
    setState(() {
      _bids = _bids
          .map((b) => b.bidId == bid.bidId ? _withStatus(b, 'rejected') : b)
          .toList();
      _workingBidId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bid rejected')),
    );
  }

  PostBid _withStatus(PostBid b, String status) => PostBid(
        bidId: b.bidId,
        bidderId: b.bidderId,
        bidderName: b.bidderName,
        bidderEmail: b.bidderEmail,
        bidderProfilePic: b.bidderProfilePic,
        message: b.message,
        posterTeachingDuration: b.posterTeachingDuration,
        bidderTeachingDuration: b.bidderTeachingDuration,
        suggestedTimeCoins: b.suggestedTimeCoins,
        acceptComment: b.acceptComment,
        status: status,
        createdAt: b.createdAt,
      );

  Widget _footerChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
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
