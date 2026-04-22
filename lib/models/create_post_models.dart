enum PostAssetType {
  skill,
  timecoin;

  String get apiValue => name.toUpperCase();
  static PostAssetType fromApi(String value) {
    return PostAssetType.values.firstWhere(
      (e) => e.apiValue == value.toUpperCase(),
      orElse: () => PostAssetType.skill,
    );
  }
}

class CreatePostState {
  CreatePostState({
    this.offerAsset = PostAssetType.skill,
    this.requestAsset = PostAssetType.skill,
    this.title = '',
    this.description = '',
    this.expiryDate,
    this.offerSkillIds = const [],
    this.requestSkillIds = const [],
    this.offerTimeCoins,
    this.requestTimeCoins,
    this.offerCourseTotalMinutes,
    this.requestCourseTotalMinutes,
    this.courseOutline = '',
  });

  final PostAssetType offerAsset;
  final PostAssetType requestAsset;
  final String title;
  final String description;
  final DateTime? expiryDate;
  final List<String> offerSkillIds;
  final List<String> requestSkillIds;
  final int? offerTimeCoins;
  final int? requestTimeCoins;
  final int? offerCourseTotalMinutes;
  final int? requestCourseTotalMinutes;
  final String courseOutline;

  CreatePostState copyWith({
    PostAssetType? offerAsset,
    PostAssetType? requestAsset,
    String? title,
    String? description,
    DateTime? expiryDate,
    List<String>? offerSkillIds,
    List<String>? requestSkillIds,
    int? offerTimeCoins,
    int? requestTimeCoins,
    int? offerCourseTotalMinutes,
    int? requestCourseTotalMinutes,
    String? courseOutline,
  }) {
    return CreatePostState(
      offerAsset: offerAsset ?? this.offerAsset,
      requestAsset: requestAsset ?? this.requestAsset,
      title: title ?? this.title,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      offerSkillIds: offerSkillIds ?? this.offerSkillIds,
      requestSkillIds: requestSkillIds ?? this.requestSkillIds,
      offerTimeCoins: offerTimeCoins ?? this.offerTimeCoins,
      requestTimeCoins: requestTimeCoins ?? this.requestTimeCoins,
      offerCourseTotalMinutes:
          offerCourseTotalMinutes ?? this.offerCourseTotalMinutes,
      requestCourseTotalMinutes:
          requestCourseTotalMinutes ?? this.requestCourseTotalMinutes,
      courseOutline: courseOutline ?? this.courseOutline,
    );
  }

  bool get isValidCombination {
    if (offerAsset == PostAssetType.timecoin &&
        requestAsset == PostAssetType.timecoin) {
      return false;
    }
    return true;
  }

  bool get canProceedToStep2 => isValidCombination;
}
