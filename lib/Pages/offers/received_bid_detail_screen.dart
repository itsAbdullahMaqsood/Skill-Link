import 'package:flutter/material.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/received_bid.dart';
import 'package:skilllink/models/exchange_type.dart';
import 'package:skilllink/Pages/offers/accept_bid_dialog.dart';
import 'package:skilllink/Pages/offers/offer_badges.dart';
import 'package:skilllink/Pages/offers/bid_sections.dart';
import 'package:skilllink/Pages/ongoing/ongoing_screen.dart';
import 'package:skilllink/Pages/profile/user_profile_detail_screen.dart';
import 'package:skilllink/Widgets/user_avatar.dart';
import 'package:skilllink/services/skill_post_service.dart';

class ReceivedBidDetailScreen extends StatefulWidget {
  final ReceivedBid bid;

  const ReceivedBidDetailScreen({super.key, required this.bid});

  @override
  State<ReceivedBidDetailScreen> createState() =>
      _ReceivedBidDetailScreenState();
}

class _ReceivedBidDetailScreenState extends State<ReceivedBidDetailScreen> {
  final SkillPostService _postService = SkillPostService();

  late ReceivedBid bid = widget.bid;
  bool _working = false;

  bool get _isActionable => bid.status.toLowerCase() == 'pending';

  Future<void> _onAccept() async {
    if ((bid.bidId ?? '').isEmpty) return;
    final accepted = await showAcceptBidDialog(
      context,
      postId: bid.postId,
      bidId: bid.bidId!,
      bidderName: bid.bidderName,
    );
    if (accepted != true || !mounted) return;

    setState(() {
      bid = ReceivedBid(
        bidId: bid.bidId,
        postId: bid.postId,
        bidderId: bid.bidderId,
        bidderName: bid.bidderName,
        bidderEmail: bid.bidderEmail,
        profilePicUrl: bid.profilePicUrl,
        postTitle: bid.postTitle,
        postOfferType: bid.postOfferType,
        postRequestType: bid.postRequestType,
        status: 'accepted',
        expiryDate: bid.expiryDate,
        message: bid.message,
        bidderTeachingDuration: bid.bidderTeachingDuration,
        posterTeachingDuration: bid.posterTeachingDuration,
        suggestedTimeCoins: bid.suggestedTimeCoins,
        bidCreatedAt: bid.bidCreatedAt,
        originalOffer: bid.originalOffer,
        originalRequest: bid.originalRequest,
      );
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

  Future<void> _onReject() async {
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
    setState(() => _working = true);
    try {
      if ((bid.bidId ?? '').isNotEmpty) {
        await _postService.rejectBid(postId: bid.postId, bidId: bid.bidId!);
      }
    } on ApiException catch (e) {
      debugPrintIfDev('rejectBid API failed: ${e.message}');
    } catch (e) {
      debugPrintIfDev('rejectBid error: $e');
    }
    if (!mounted) return;
    setState(() {
      bid = ReceivedBid(
        bidId: bid.bidId,
        postId: bid.postId,
        bidderId: bid.bidderId,
        bidderName: bid.bidderName,
        bidderEmail: bid.bidderEmail,
        profilePicUrl: bid.profilePicUrl,
        postTitle: bid.postTitle,
        postOfferType: bid.postOfferType,
        postRequestType: bid.postRequestType,
        status: 'rejected',
        expiryDate: bid.expiryDate,
        message: bid.message,
        bidderTeachingDuration: bid.bidderTeachingDuration,
        posterTeachingDuration: bid.posterTeachingDuration,
        suggestedTimeCoins: bid.suggestedTimeCoins,
        bidCreatedAt: bid.bidCreatedAt,
        originalOffer: bid.originalOffer,
        originalRequest: bid.originalRequest,
      );
      _working = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bid rejected')),
    );
  }

  void debugPrintIfDev(String msg) {
    // ignore: avoid_print
    print('[ReceivedBidDetail] $msg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Received Bid Details'),
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
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildBidderInfo(context),
                  const SizedBox(height: 20),
                  _buildSection(
                    child: buildBidSection(
                      label: 'Original:',
                      labelColor: Colors.grey.shade800,
                      offer: bid.originalOffer,
                      request: bid.originalRequest,
                      offerType: bid.postOfferType,
                      requestType: bid.postRequestType,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    child: buildCounterSection(
                      label: 'Their Counter',
                      accentColor: Colors.orange.shade700,
                      offerType: bid.postOfferType,
                      requestType: bid.postRequestType,
                      counterTimeCoins: bid.suggestedTimeCoins,
                      counterBidderTeachingDuration: bid.bidderTeachingDuration,
                      counterPosterTeachingDuration: bid.posterTeachingDuration,
                    ),
                  ),
                  if (bid.message != null && bid.message!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildMessageSection(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  bid.postTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              buildExchangeTypeBadge(
                type: bid.isSkillExchange
                    ? ExchangeType.skillExchange
                    : ExchangeType.timecoinExchange,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBidStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildBidStatusBadge() {
    Color bg;
    Color fg;
    switch (bid.status.toLowerCase()) {
      case 'accepted':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        break;
      case 'rejected':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        break;
      default:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        bid.status[0].toUpperCase() + bid.status.substring(1),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _buildBidderInfo(BuildContext context) {
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
            onTap: () => openUserProfileDetail(context, bid.bidderId),
            child: UserAvatar(
              imageRef: bid.profilePicUrl,
              radius: 22,
              backgroundColor: Colors.orange.shade100,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bid from',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bid.bidderName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (bid.bidderEmail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    bid.bidderEmail,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildMessageSection() {
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
              Icon(Icons.message_outlined,
                  size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Their Message',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            bid.message!,
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
        spacing: 12,
        runSpacing: 10,
        children: [
          if (bid.bidCreatedAt != null)
            _metaChip(
              icon: Icons.access_time,
              text: 'Received ${timeAgo(bid.bidCreatedAt)}',
            ),
          _metaChip(
            icon: Icons.hourglass_bottom,
            text: bid.expiryDate != null
                ? _expiryText(bid.expiryDate!)
                : 'No expiry',
            isWarning: bid.expiryDate != null &&
                bid.expiryDate!.isBefore(
                    DateTime.now().add(const Duration(days: 3))),
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
      child: _isActionable
          ? Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _working ? null : _onAccept,
                    icon: _working
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Accept',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.green.shade300,
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _working ? null : _onReject,
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Reject',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      bid.status.toLowerCase() == 'accepted'
                          ? 'Bid accepted'
                          : 'Bid ${bid.status.toLowerCase()}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _expiryText(DateTime date) {
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays == 0) return 'Expires today';
    if (diff.inDays == 1) return 'Expires tomorrow';
    return 'Expires in ${diff.inDays} days';
  }
}
