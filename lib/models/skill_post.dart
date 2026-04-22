import 'package:skilllink/models/exchange_type.dart';
import 'package:skilllink/models/recommendation.dart';
import 'package:skilllink/models/skill_post_dto.dart';

class SkillPost extends Recommendation {
  final String title;
  final String description;
  final String postStatus;
  final String offerType;
  final String requestType;
  final bool matchesMySkills;
  final DateTime? createdAt;
  final DateTime? expiryDate;
  final int? offerTimeCoins;
  final int? requestTimeCoins;
  final int? courseTotalMinutes;
  final int? desiredDurationMinutes;
  final String? courseOutline;
  final String? offerGoals;
  final String? requestGoals;
  final bool? hasUserBid;
  final String creatorUserId;

  SkillPost({
    required super.id,
    required super.name,
    required super.profileImage,
    required super.isVerified,
    required super.rating,
    required super.status,
    required super.matchPercentage,
    super.isTopRated,
    required super.offers,
    required super.needs,
    required super.exchangeType,
    super.timecoinCost,
    required this.title,
    required this.description,
    required this.postStatus,
    required this.offerType,
    required this.requestType,
    required this.matchesMySkills,
    this.createdAt,
    this.expiryDate,
    this.offerTimeCoins,
    this.requestTimeCoins,
    this.courseTotalMinutes,
    this.desiredDurationMinutes,
    this.courseOutline,
    this.offerGoals,
    this.requestGoals,
    this.hasUserBid = false,
    this.creatorUserId = '',
  });

  SkillPost copyWith({bool? hasUserBid, String? creatorUserId}) {
    return SkillPost(
      id: id,
      name: name,
      profileImage: profileImage,
      isVerified: isVerified,
      rating: rating,
      status: status,
      matchPercentage: matchPercentage,
      isTopRated: isTopRated,
      offers: offers,
      needs: needs,
      exchangeType: exchangeType,
      timecoinCost: timecoinCost,
      title: title,
      description: description,
      postStatus: postStatus,
      offerType: offerType,
      requestType: requestType,
      matchesMySkills: matchesMySkills,
      createdAt: createdAt,
      expiryDate: expiryDate,
      offerTimeCoins: offerTimeCoins,
      requestTimeCoins: requestTimeCoins,
      courseTotalMinutes: courseTotalMinutes,
      desiredDurationMinutes: desiredDurationMinutes,
      courseOutline: courseOutline,
      offerGoals: offerGoals,
      requestGoals: requestGoals,
      hasUserBid: hasUserBid ?? this.hasUserBid,
      creatorUserId: creatorUserId ?? this.creatorUserId,
    );
  }

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());
}

class PaginatedSkillPosts {
  final List<SkillPost> posts;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  PaginatedSkillPosts({
    required this.posts,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });
}

class SkillPostMapper {
  static SkillPost fromDto(SkillPostDto dto) {
    final user = dto.user;
    final offer = dto.offer;
    final request = dto.request;

    final offerSkills =
        offer?.skills.map((s) => s.name).where((n) => n.isNotEmpty).toList() ??
        [];
    final requestSkills =
        request?.skills
            .map((s) => s.name)
            .where((n) => n.isNotEmpty)
            .toList() ??
        [];

    final isTimecoinOffer = dto.offerType.toUpperCase() == 'TIMECOIN';
    final isTimecoinRequest = dto.requestType.toUpperCase() == 'TIMECOIN';

    ExchangeType exchangeType;
    int? timecoinCost;
    if (isTimecoinOffer || isTimecoinRequest) {
      exchangeType = ExchangeType.timecoinExchange;
      timecoinCost = offer?.timeCoins ?? request?.timeCoins;
    } else {
      exchangeType = ExchangeType.skillExchange;
    }

    return SkillPost(
      id: dto.id,
      name: user?.fullName ?? 'Unknown',
      profileImage: user?.profilePic ?? '',
      isVerified: user?.verified ?? false,
      rating: user?.ratings ?? 0.0,
      status: dto.status,
      matchPercentage: dto.matchesMySkills ? 100 : 0,
      isTopRated: false,
      offers: offerSkills,
      needs: requestSkills,
      exchangeType: exchangeType,
      timecoinCost: timecoinCost,
      title: dto.title,
      description: dto.description,
      postStatus: dto.status,
      offerType: dto.offerType,
      requestType: dto.requestType,
      matchesMySkills: dto.matchesMySkills,
      createdAt: dto.createdAt,
      expiryDate: dto.expiryDate,
      offerTimeCoins: offer?.timeCoins,
      requestTimeCoins: request?.timeCoins,
      courseTotalMinutes: offer?.courseTotalMinutes,
      desiredDurationMinutes: request?.desiredDurationMinutes,
      courseOutline: offer?.courseOutline,
      offerGoals: offer?.goals,
      requestGoals: request?.goals,
      hasUserBid: dto.hasUserBid,
      creatorUserId: user?.id ?? '',
    );
  }

  static PaginatedSkillPosts fromPaginatedDto(PaginatedSkillPostsDto dto) {
    return PaginatedSkillPosts(
      posts: dto.posts.map(fromDto).toList(),
      total: dto.total,
      limit: dto.limit,
      offset: dto.offset,
      hasMore: dto.hasMore,
    );
  }
}
