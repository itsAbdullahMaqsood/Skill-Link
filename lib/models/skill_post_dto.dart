
class SkillPostDto {
  final String id;
  final String title;
  final String description;
  final String status;
  final String offerType;
  final String requestType;
  final bool matchesMySkills;
  final DateTime? createdAt;
  final DateTime? expiryDate;
  final SkillPostUserDto? user;
  final RequirementDto? offer;
  final RequirementDto? request;
  final bool hasUserBid;

  SkillPostDto({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.offerType,
    required this.requestType,
    required this.matchesMySkills,
    this.createdAt,
    this.expiryDate,
    this.user,
    this.offer,
    this.request,
    this.hasUserBid = false,
  });

  factory SkillPostDto.fromJson(Map<String, dynamic> json) {
    final postId = (json['_id'] ?? json['id'] ?? '').toString();

    final parsed = _parseRequirements(json);

    return SkillPostDto(
      id: postId,
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      offerType: (json['offer_type'] ?? json['offerType'] ?? '').toString(),
      requestType:
          (json['request_type'] ?? json['requestType'] ?? '').toString(),
      matchesMySkills: json['matchesMySkills'] == true,
      hasUserBid: json['has_user_bid'] == true,
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      expiryDate: _parseDate(json['expiryDate'] ?? json['expiry_date']),
      user: _parseUser(json),
      offer: parsed['offer'],
      request: parsed['request'],
    );
  }

  static Map<String, RequirementDto?> _parseRequirements(
      Map<String, dynamic> json) {
    RequirementDto? offer;
    RequirementDto? request;

    final reqs = json['requirements'];
    if (reqs is List) {
      for (final r in reqs) {
        if (r is Map<String, dynamic>) {
          final side = (r['side'] ?? '').toString().toUpperCase();
          if (side == 'OFFER') {
            offer = RequirementDto.fromJson(r);
          } else if (side == 'REQUEST') {
            request = RequirementDto.fromJson(r);
          }
        }
      }
    }

    offer ??= json['offer'] is Map<String, dynamic>
        ? RequirementDto.fromJson(json['offer'] as Map<String, dynamic>)
        : null;
    request ??= json['request'] is Map<String, dynamic>
        ? RequirementDto.fromJson(json['request'] as Map<String, dynamic>)
        : null;

    return {'offer': offer, 'request': request};
  }

  static SkillPostUserDto? _parseUser(Map<String, dynamic> json) {
    final raw = json['created_by'] ?? json['createdBy'] ?? json['user'];
    if (raw is Map<String, dynamic>) return SkillPostUserDto.fromJson(raw);
    if (raw is String && raw.trim().isNotEmpty) {
      return SkillPostUserDto.fromJson({
        '_id': raw,
        'fullName':
            json['created_by_name'] ?? json['creator_name'] ?? json['fullName'],
        'profilePic': json['profilePic'] ??
            json['profile_pic'] ??
            json['profile_pic_url'] ??
            json['profileImage'] ??
            json['profile_image'] ??
            json['avatar'] ??
            json['image'],
        'verified': json['verified'] ?? json['is_verified'],
        'ratings': json['ratings'] ?? json['rating'],
      });
    }
    final fallbackName =
        json['created_by_name'] ?? json['creator_name'] ?? json['fullName'];
    final fallbackPic = json['profilePic'] ??
        json['profile_pic'] ??
        json['profile_pic_url'] ??
        json['profileImage'] ??
        json['profile_image'] ??
        json['avatar'] ??
        json['image'];
    if (fallbackName != null || fallbackPic != null) {
      return SkillPostUserDto.fromJson({
        '_id': json['creator_id'] ?? json['created_by_id'] ?? '',
        'fullName': fallbackName,
        'profilePic': fallbackPic,
        'verified': json['verified'] ?? json['is_verified'],
        'ratings': json['ratings'] ?? json['rating'],
      });
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class RequirementDto {
  final String assetType;
  final List<SkillRefDto> skills;
  final int? timeCoins;
  final int? courseTotalMinutes;
  final int? desiredDurationMinutes;
  final String? courseOutline;
  final String? goals;

  RequirementDto({
    required this.assetType,
    required this.skills,
    this.timeCoins,
    this.courseTotalMinutes,
    this.desiredDurationMinutes,
    this.courseOutline,
    this.goals,
  });

  factory RequirementDto.fromJson(Map<String, dynamic> json) {
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

    return RequirementDto(
      assetType:
          (json['asset_type'] ?? json['assetType'] ?? '').toString(),
      skills: skillsList,
      timeCoins: _parseInt(json['time_coins'] ?? json['timeCoins']),
      courseTotalMinutes: _parseInt(
          json['course_total_minutes'] ?? json['courseTotalMinutes']),
      desiredDurationMinutes: _parseInt(
          json['desired_duration_minutes'] ?? json['desiredDurationMinutes']),
      courseOutline:
          (json['course_outline'] ?? json['courseOutline'])?.toString(),
      goals: (json['goals'])?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class SkillRefDto {
  final String id;
  final String name;

  SkillRefDto({required this.id, required this.name});

  factory SkillRefDto.fromJson(Map<String, dynamic> json) {
    return SkillRefDto(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
    );
  }
}

class SkillPostUserDto {
  final String id;
  final String fullName;
  final String? profilePic;
  final bool verified;
  final double ratings;

  SkillPostUserDto({
    required this.id,
    required this.fullName,
    this.profilePic,
    required this.verified,
    required this.ratings,
  });

  factory SkillPostUserDto.fromJson(Map<String, dynamic> json) {
    return SkillPostUserDto(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['full_name'] ?? '').toString(),
      profilePic: json['profilePic']?.toString() ??
          json['profile_pic']?.toString() ??
          json['profile_pic_url']?.toString() ??
          json['profileImage']?.toString() ??
          json['profile_image']?.toString() ??
          json['avatar']?.toString() ??
          json['image']?.toString(),
      verified: json['verified'] == true,
      ratings: (json['ratings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaginatedSkillPostsDto {
  final List<SkillPostDto> posts;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  PaginatedSkillPostsDto({
    required this.posts,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory PaginatedSkillPostsDto.fromJson(Map<String, dynamic> json) {
    final rawPosts = json['posts'];
    final posts = <SkillPostDto>[];
    if (rawPosts is List) {
      for (final p in rawPosts) {
        if (p is Map<String, dynamic>) {
          posts.add(SkillPostDto.fromJson(p));
        }
      }
    }
    return PaginatedSkillPostsDto(
      posts: posts,
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] == true,
    );
  }
}
