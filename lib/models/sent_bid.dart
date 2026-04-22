import 'package:skilllink/models/skill_post.dart';
import 'package:skilllink/models/skill_post_dto.dart';

class SentBid {
  final String postId;
  final String title;
  final String offerType;
  final String requestType;
  final String status;
  final DateTime? expiryDate;
  final String creatorName;
  final String? creatorProfilePic;
  final String creatorUserId;

  final BidRequirement? originalOffer;
  final BidRequirement? originalRequest;

  final int? suggestedTimeCoins;
  final int? bidderTeachingDuration;
  final int? posterTeachingDuration;
  final String? bidMessage;
  final DateTime? bidCreatedAt;

  SentBid({
    required this.postId,
    required this.title,
    required this.offerType,
    required this.requestType,
    required this.status,
    this.expiryDate,
    required this.creatorName,
    this.creatorProfilePic,
    this.creatorUserId = '',
    this.originalOffer,
    this.originalRequest,
    this.suggestedTimeCoins,
    this.bidderTeachingDuration,
    this.posterTeachingDuration,
    this.bidMessage,
    this.bidCreatedAt,
  });

  factory SentBid.fromJson(Map<String, dynamic> json) {
    final createdBy = json['created_by'] ?? json['createdBy'];
    String creatorName = '';
    String? creatorPic;
    String creatorUserId = '';
    if (createdBy is Map<String, dynamic>) {
      creatorUserId =
          (createdBy['_id'] ?? createdBy['id'] ?? '').toString();
      creatorName = (createdBy['fullName'] ?? createdBy['full_name'] ?? '').toString();
      creatorPic = createdBy['profilePic']?.toString() ??
          createdBy['profile_pic']?.toString() ??
          createdBy['profile_pic_url']?.toString();
    }

    final reqs = _parseRequirements(json['requirements']);

    return SentBid(
      postId: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      offerType: (json['offer_type'] ?? json['offerType'] ?? '').toString(),
      requestType: (json['request_type'] ?? json['requestType'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      expiryDate: _parseDate(json['bid_expiry_date'] ?? json['bidExpiryDate']),
      creatorName: creatorName,
      creatorProfilePic: creatorPic,
      creatorUserId: creatorUserId,
      originalOffer: reqs['offer'],
      originalRequest: reqs['request'],
      suggestedTimeCoins: _parseInt(json['suggested_time_coins']),
      bidderTeachingDuration: _parseInt(json['course_timeline']),
      posterTeachingDuration: _parseInt(json['proposed_timeline']),
      bidMessage: json['bid_message']?.toString(),
      bidCreatedAt: _parseDate(json['bid_created_at']),
    );
  }

  factory SentBid.fromPostAndBidJson(
    dynamic post,
    Map<String, dynamic> bidJson,
  ) {
    final String postId = post.id as String;
    final String title = post.title as String;
    final String offerType = post.offerType as String;
    final String requestType = post.requestType as String;
    final String creatorName = post.name as String;
    final String profileImage = post.profileImage as String;
    final String creatorUserId =
        post is SkillPost ? post.creatorUserId : '';

    BidRequirement? originalOffer;
    if (offerType.toUpperCase() == 'SKILL') {
      originalOffer = BidRequirement(
        assetType: 'SKILL',
        skills: (post.offers as List<String>)
            .map((n) => SkillRefDto(id: '', name: n))
            .toList(),
        courseTotalMinutes: post.courseTotalMinutes as int?,
        courseOutline: post.courseOutline as String?,
      );
    } else {
      originalOffer = BidRequirement(
        assetType: 'TIMECOIN',
        skills: [],
        timeCoins: post.offerTimeCoins as int?,
      );
    }

    BidRequirement? originalRequest;
    if (requestType.toUpperCase() == 'SKILL') {
      originalRequest = BidRequirement(
        assetType: 'SKILL',
        skills: (post.needs as List<String>)
            .map((n) => SkillRefDto(id: '', name: n))
            .toList(),
        desiredDurationMinutes: post.desiredDurationMinutes as int?,
      );
    } else {
      originalRequest = BidRequirement(
        assetType: 'TIMECOIN',
        skills: [],
        timeCoins: post.requestTimeCoins as int?,
      );
    }

    return SentBid(
      postId: postId,
      title: title,
      offerType: offerType,
      requestType: requestType,
      status: (bidJson['status'] ?? 'pending').toString(),
      creatorName: creatorName,
      creatorProfilePic: profileImage.isNotEmpty ? profileImage : null,
      creatorUserId: creatorUserId,
      originalOffer: originalOffer,
      originalRequest: originalRequest,
      suggestedTimeCoins: _parseInt(bidJson['suggested_time_coins']),
      bidderTeachingDuration: _parseInt(bidJson['course_timeline']),
      posterTeachingDuration: _parseInt(bidJson['proposed_timeline']),
      bidMessage: bidJson['message']?.toString(),
      bidCreatedAt: _parseDate(bidJson['createdAt']),
    );
  }

  bool get isOfferSkill => offerType.toUpperCase() == 'SKILL';
  bool get isRequestSkill => requestType.toUpperCase() == 'SKILL';
  bool get isSkillExchange => isOfferSkill && isRequestSkill;

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

class BidRequirement {
  final String assetType;
  final List<SkillRefDto> skills;
  final int? timeCoins;
  final int? courseTotalMinutes;
  final int? desiredDurationMinutes;
  final String? courseOutline;

  BidRequirement({
    required this.assetType,
    required this.skills,
    this.timeCoins,
    this.courseTotalMinutes,
    this.desiredDurationMinutes,
    this.courseOutline,
  });

  factory BidRequirement.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['skill_ids'] ?? json['skillIds'] ?? [];
    final skillsList = <SkillRefDto>[];
    if (rawSkills is List) {
      for (final s in rawSkills) {
        if (s is Map<String, dynamic>) {
          skillsList.add(SkillRefDto.fromJson(s));
        } else if (s is String) {
          skillsList.add(SkillRefDto(id: s, name: s));
        }
      }
    }
    return BidRequirement(
      assetType: (json['asset_type'] ?? json['assetType'] ?? '').toString(),
      skills: skillsList,
      timeCoins: _parseInt(json['time_coins'] ?? json['timeCoins']),
      courseTotalMinutes: _parseInt(json['course_total_minutes'] ?? json['courseTotalMinutes']),
      desiredDurationMinutes: _parseInt(json['desired_duration_minutes'] ?? json['desiredDurationMinutes']),
      courseOutline: (json['course_outline'] ?? json['courseOutline'])?.toString(),
    );
  }

  bool get isSkill => assetType.toUpperCase() == 'SKILL';

  int? get durationMinutes => courseTotalMinutes ?? desiredDurationMinutes;

  List<String> get skillNames => skills.map((s) => s.name).where((n) => n.isNotEmpty).toList();

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class PaginatedSentBids {
  final List<SentBid> posts;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  PaginatedSentBids({
    required this.posts,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory PaginatedSentBids.fromJson(Map<String, dynamic> json) {
    final rawPosts = json['posts'];
    final posts = <SentBid>[];
    if (rawPosts is List) {
      for (final p in rawPosts) {
        if (p is Map<String, dynamic>) {
          posts.add(SentBid.fromJson(p));
        }
      }
    }
    return PaginatedSentBids(
      posts: posts,
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] == true,
    );
  }
}
