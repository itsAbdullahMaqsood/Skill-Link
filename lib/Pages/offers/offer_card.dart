import 'package:flutter/material.dart';
import 'package:skilllink/models/exchange_type.dart';
import 'package:skilllink/models/sent_bid.dart';
import 'package:skilllink/Pages/offers/offer_badges.dart';
import 'package:skilllink/Pages/offers/bid_sections.dart';
import 'package:skilllink/Pages/offers/sent_bid_detail_screen.dart';
import 'package:skilllink/Pages/profile/user_profile_detail_screen.dart';
import 'package:skilllink/Widgets/user_avatar.dart';

class OfferCard extends StatelessWidget {
  final SentBid bid;

  const OfferCard({super.key, required this.bid});

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = bid.expiryDate != null
        ? bid.expiryDate!.difference(DateTime.now()).inDays
        : null;

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
              MaterialPageRoute(builder: (_) => SentBidDetailScreen(bid: bid)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildSentTo(context),
                const Divider(height: 24),
                buildBidSection(
                  label: 'Original:',
                  labelColor: Colors.grey.shade800,
                  offer: bid.originalOffer,
                  request: bid.originalRequest,
                  offerType: bid.offerType,
                  requestType: bid.requestType,
                ),
                const Divider(height: 24),
                buildCounterSection(
                  label: 'Your Counter',
                  accentColor: Colors.blue.shade700,
                  offerType: bid.offerType,
                  requestType: bid.requestType,
                  counterTimeCoins: bid.suggestedTimeCoins,
                  counterBidderTeachingDuration: bid.bidderTeachingDuration,
                  counterPosterTeachingDuration: bid.posterTeachingDuration,
                ),
                const Divider(height: 24),
                _buildFooter(daysUntilExpiry),
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
            bid.title,
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

  Widget _buildSentTo(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openUserProfileDetail(context, bid.creatorUserId),
          child: UserAvatar(
            imageRef: bid.creatorProfilePic,
            radius: 14,
            backgroundColor: Colors.blue.shade100,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Sent to ${bid.creatorName}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        buildStatusBadge(bid.status),
      ],
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
            icon: Icons.send,
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
}
