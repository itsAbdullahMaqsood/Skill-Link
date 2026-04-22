import 'package:flutter/material.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/sent_bid.dart';
import 'package:skilllink/models/exchange_type.dart';
import 'package:skilllink/Pages/offers/offer_badges.dart';
import 'package:skilllink/Pages/offers/bid_sections.dart';
import 'package:skilllink/services/skill_post_service.dart';
import 'package:skilllink/Pages/profile/user_profile_detail_screen.dart';
import 'package:skilllink/Widgets/user_avatar.dart';

class SentBidDetailScreen extends StatefulWidget {
  final SentBid bid;

  const SentBidDetailScreen({super.key, required this.bid});

  @override
  State<SentBidDetailScreen> createState() => _SentBidDetailScreenState();
}

class _SentBidDetailScreenState extends State<SentBidDetailScreen> {
  SentBid get bid => widget.bid;
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Sent Bid Details'),
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
                  _buildRecipientInfo(context),
                  const SizedBox(height: 20),
                  _buildSection(
                    child: buildBidSection(
                      label: 'Original:',
                      labelColor: Colors.grey.shade800,
                      offer: bid.originalOffer,
                      request: bid.originalRequest,
                      offerType: bid.offerType,
                      requestType: bid.requestType,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    child: buildCounterSection(
                      label: 'Your Counter',
                      accentColor: Colors.blue.shade700,
                      offerType: bid.offerType,
                      requestType: bid.requestType,
                      counterTimeCoins: bid.suggestedTimeCoins,
                      counterBidderTeachingDuration: bid.bidderTeachingDuration,
                      counterPosterTeachingDuration: bid.posterTeachingDuration,
                    ),
                  ),
                  if (bid.bidMessage != null && bid.bidMessage!.isNotEmpty) ...[
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

  Future<void> _handleCancelBid() async {
    setState(() => _isCancelling = true);
    try {
      final result = await SkillPostService().cancelBid(postId: bid.postId);
      if (!mounted) return;
      final msg = (result['message'] as String?) ?? 'Bid cancelled';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
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
      if (mounted) setState(() => _isCancelling = false);
    }
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
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isCancelling ? null : _handleCancelBid,
          icon: _isCancelling
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cancel_outlined, size: 18),
          label: Text(
            _isCancelling ? 'Cancelling...' : 'Cancel Bid',
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
                  bid.title,
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
          buildStatusBadge(bid.status),
        ],
      ),
    );
  }

  Widget _buildRecipientInfo(BuildContext context) {
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
            onTap: () => openUserProfileDetail(context, bid.creatorUserId),
            child: UserAvatar(
              imageRef: bid.creatorProfilePic,
              radius: 22,
              backgroundColor: Colors.blue.shade100,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sent to',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bid.creatorName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
              Icon(
                Icons.message_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Message',
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
            bid.bidMessage!,
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
              icon: Icons.send,
              text: 'Sent ${timeAgo(bid.bidCreatedAt)}',
            ),
          _metaChip(
            icon: Icons.hourglass_bottom,
            text: bid.expiryDate != null
                ? _expiryText(bid.expiryDate!)
                : 'No expiry',
            isWarning:
                bid.expiryDate != null &&
                bid.expiryDate!.isBefore(
                  DateTime.now().add(const Duration(days: 3)),
                ),
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

  String _expiryText(DateTime date) {
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays == 0) return 'Expires today';
    if (diff.inDays == 1) return 'Expires tomorrow';
    return 'Expires in ${diff.inDays} days';
  }
}
