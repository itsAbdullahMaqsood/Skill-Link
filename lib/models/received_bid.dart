import 'package:skilllink/models/sent_bid.dart';

class ReceivedBid {
  final String? bidId;
  final String postId;
  final String bidderId;
  final String bidderName;
  final String bidderEmail;
  final String? profilePicUrl;
  final String postTitle;
  final String postOfferType;
  final String postRequestType;
  final String status;
  final DateTime? expiryDate;
  final String? message;
  final int? bidderTeachingDuration;
  final int? posterTeachingDuration;
  final int? suggestedTimeCoins;
  final DateTime? bidCreatedAt;

  final BidRequirement? originalOffer;
  final BidRequirement? originalRequest;

  ReceivedBid({
    this.bidId,
    required this.postId,
    required this.bidderId,
    required this.bidderName,
    required this.bidderEmail,
    this.profilePicUrl,
    required this.postTitle,
    required this.postOfferType,
    required this.postRequestType,
    required this.status,
    this.expiryDate,
    this.message,
    this.bidderTeachingDuration,
    this.posterTeachingDuration,
    this.suggestedTimeCoins,
    this.bidCreatedAt,
    this.originalOffer,
    this.originalRequest,
  });

  bool get isOfferSkill => postOfferType.toUpperCase() == 'SKILL';
  bool get isRequestSkill => postRequestType.toUpperCase() == 'SKILL';
  bool get isSkillExchange => isOfferSkill && isRequestSkill;

  factory ReceivedBid.fromJson(Map<String, dynamic> json) {
    final reqs = _parseRequirements(json['requirements']);

    return ReceivedBid(
      bidId: json['bid_id']?.toString() ?? json['bidId']?.toString(),
      postId: (json['postId'] ?? json['post_id'] ?? '').toString(),
      bidderId: (json['bidder_id'] ?? '').toString(),
      bidderName: (json['bidder_name'] ?? '').toString(),
      bidderEmail: (json['bidder_email'] ?? '').toString(),
      profilePicUrl: json['profile_pic_url']?.toString(),
      postTitle: (json['post_title'] ?? '').toString(),
      postOfferType: (json['post_offer_type'] ?? '').toString(),
      postRequestType: (json['post_request_type'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      expiryDate: _parseDate(json['expiry_date']),
      message: json['message']?.toString(),
      bidderTeachingDuration: _parseInt(json['course_timeline']),
      posterTeachingDuration: _parseInt(json['proposed_timeline']),
      suggestedTimeCoins: _parseInt(json['suggested_time_coins']),
      bidCreatedAt: _parseDate(json['bid_created_at']),
      originalOffer: reqs['offer'],
      originalRequest: reqs['request'],
    );
  }

  static Map<String, BidRequirement?> _parseRequirements(dynamic reqs) {
    BidRequirement? offer;
    BidRequirement? request;
    if (reqs is List) {
      for (final r in reqs) {
        if (r is Map<String, dynamic>) {
          final side = (r['side'] ?? '').toString().toUpperCase();
          if (side == 'OFFER') {
            offer = BidRequirement.fromJson(r);
          } else if (side == 'REQUEST') {
            request = BidRequirement.fromJson(r);
          }
        }
      }
    }
    return {'offer': offer, 'request': request};
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class PaginatedReceivedBids {
  final List<ReceivedBid> bids;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  PaginatedReceivedBids({
    required this.bids,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory PaginatedReceivedBids.fromJson(Map<String, dynamic> json) {
    final rawBids = json['bids'];
    final bids = <ReceivedBid>[];
    if (rawBids is List) {
      for (final b in rawBids) {
        if (b is Map<String, dynamic>) {
          bids.add(ReceivedBid.fromJson(b));
        }
      }
    }
    return PaginatedReceivedBids(
      bids: bids,
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] == true,
    );
  }
}
