import 'package:flutter/material.dart';
import 'package:skilllink/models/received_bid.dart';
import 'package:skilllink/models/exchange_type.dart';
import 'package:skilllink/Pages/offers/offer_badges.dart';
import 'package:skilllink/Pages/offers/bid_sections.dart';
import 'package:skilllink/Pages/offers/received_bid_detail_screen.dart';
import 'package:skilllink/Pages/profile/user_profile_detail_screen.dart';
import 'package:skilllink/Widgets/user_avatar.dart';

class ReceivedBidCard extends StatelessWidget {
  final ReceivedBid bid;

  const ReceivedBidCard({super.key, required this.bid});

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = bid.expiryDate?.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReceivedBidDetailScreen(bid: bid),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildBidderInfo(context),
                const Divider(height: 24),
                buildBidSection(
                  label: 'Original:',
                  labelColor: Colors.grey.shade800,
                  offer: bid.originalOffer,
                  request: bid.originalRequest,
                  offerType: bid.postOfferType,
                  requestType: bid.postRequestType,
                ),
                const Divider(height: 24),
                buildCounterSection(
                  label: 'Their Counter',
                  accentColor: Colors.orange.shade700,
                  offerType: bid.postOfferType,
                  requestType: bid.postRequestType,
                  counterTimeCoins: bid.suggestedTimeCoins,
                  counterBidderTeachingDuration: bid.bidderTeachingDuration,
                  counterPosterTeachingDuration: bid.posterTeachingDuration,
                ),
                if (bid.message != null && bid.message!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildMessageSection(),
                ],
                const Divider(height: 24),
                _buildFooter(daysUntilExpiry),
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            bid.postTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        buildExchangeTypeBadge(
          type: bid.isSkillExchange
              ? ExchangeType.skillExchange
              : ExchangeType.timecoinExchange,
        ),
      ],
    );
  }

  Widget _buildBidderInfo(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openUserProfileDetail(context, bid.bidderId),
          child: UserAvatar(
            imageRef: bid.profilePicUrl,
            radius: 14,
            backgroundColor: Colors.orange.shade100,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Bid from ${bid.bidderName}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        _buildBidStatusBadge(),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        bid.status[0].toUpperCase() + bid.status.substring(1),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _buildMessageSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.message_outlined, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              bid.message!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(int? daysUntilExpiry) {
    return Row(
      children: [
        _buildFooterChip(
          icon: Icons.hourglass_bottom,
          text: daysUntilExpiry == null
              ? 'No expiry'
              : daysUntilExpiry <= 0
              ? 'Expired'
              : daysUntilExpiry == 1
              ? 'Expires tomorrow'
              : 'Expires in $daysUntilExpiry days',
          isWarning: daysUntilExpiry != null && daysUntilExpiry <= 3,
        ),
        const Spacer(),
        if (bid.bidCreatedAt != null)
          _buildFooterChip(
            icon: Icons.access_time,
            text: 'Sent ${timeAgo(bid.bidCreatedAt)}',
            isWarning: false,
          ),
      ],
    );
  }

  Widget _buildFooterChip({
    required IconData icon,
    required String text,
    required bool isWarning,
  }) {
    final color = isWarning ? Colors.red : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color.shade700),
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Accept bid — coming soon'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text(
              'Accept',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reject bid — coming soon'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text(
              'Reject',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
