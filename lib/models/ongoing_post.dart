
enum OngoingRole { owner, counterparty }

class OngoingPostUser {
  final String id;
  final String fullName;
  final String? email;
  final String? profilePicUrl;

  const OngoingPostUser({
    required this.id,
    required this.fullName,
    this.email,
    this.profilePicUrl,
  });

  factory OngoingPostUser.fromJson(Map<String, dynamic> json) {
    return OngoingPostUser(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['full_name'] ?? '').toString(),
      email: json['email']?.toString(),
      profilePicUrl: (json['profile_pic_url'] ??
              json['profilePicUrl'] ??
              json['profilePic'] ??
              json['profile_pic'])
          ?.toString(),
    );
  }
}

class OngoingPost {
  final String id;
  final String title;
  final String description;
  final String requestType;
  final String offerType;
  final String status;
  final DateTime? expiryDate;
  final int? acceptedTimeCoins;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? selectedBidId;
  final OngoingPostUser? postOwner;
  final OngoingPostUser? counterparty;
  final OngoingRole myRole;
  final DateTime? bidAcceptedAt;

  const OngoingPost({
    required this.id,
    required this.title,
    required this.description,
    required this.requestType,
    required this.offerType,
    required this.status,
    required this.myRole,
    this.expiryDate,
    this.acceptedTimeCoins,
    this.createdAt,
    this.updatedAt,
    this.selectedBidId,
    this.postOwner,
    this.counterparty,
    this.bidAcceptedAt,
  });

  bool get isOwner => myRole == OngoingRole.owner;
  bool get isOngoing => status.toLowerCase() == 'ongoing';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isSkillExchange =>
      offerType.toUpperCase() == 'SKILL' && requestType.toUpperCase() == 'SKILL';

  OngoingPostUser? get otherUser => isOwner ? counterparty : postOwner;

  OngoingPost copyWith({String? status}) {
    return OngoingPost(
      id: id,
      title: title,
      description: description,
      requestType: requestType,
      offerType: offerType,
      status: status ?? this.status,
      myRole: myRole,
      expiryDate: expiryDate,
      acceptedTimeCoins: acceptedTimeCoins,
      createdAt: createdAt,
      updatedAt: updatedAt,
      selectedBidId: selectedBidId,
      postOwner: postOwner,
      counterparty: counterparty,
      bidAcceptedAt: bidAcceptedAt,
    );
  }

  factory OngoingPost.fromJson(Map<String, dynamic> json) {
    final ownerRaw = json['post_owner'];
    final counterRaw = json['counterparty'];
    final roleRaw = (json['my_role'] ?? '').toString().toLowerCase();
    return OngoingPost(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      requestType:
          (json['request_type'] ?? json['requestType'] ?? '').toString(),
      offerType: (json['offer_type'] ?? json['offerType'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      expiryDate: _parseDate(json['expiry_date'] ?? json['expiryDate']),
      acceptedTimeCoins:
          _parseInt(json['accepted_time_coins'] ?? json['acceptedTimeCoins']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
      selectedBidId:
          (json['selected_bid_id'] ?? json['selectedBidId'])?.toString(),
      postOwner: ownerRaw is Map<String, dynamic>
          ? OngoingPostUser.fromJson(ownerRaw)
          : null,
      counterparty: counterRaw is Map<String, dynamic>
          ? OngoingPostUser.fromJson(counterRaw)
          : null,
      myRole: roleRaw == 'owner' ? OngoingRole.owner : OngoingRole.counterparty,
      bidAcceptedAt:
          _parseDate(json['bid_accepted_at'] ?? json['bidAcceptedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class PaginatedOngoingPosts {
  final List<OngoingPost> posts;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  const PaginatedOngoingPosts({
    required this.posts,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory PaginatedOngoingPosts.fromJson(Map<String, dynamic> json) {
    final raw = json['posts'];
    final out = <OngoingPost>[];
    if (raw is List) {
      for (final p in raw) {
        if (p is Map<String, dynamic>) {
          out.add(OngoingPost.fromJson(p));
        }
      }
    }
    return PaginatedOngoingPosts(
      posts: out,
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] == true,
    );
  }
}
