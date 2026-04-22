import 'package:skilllink/models/exchange_type.dart';

class Offer {
  final String id;
  final String userId;
  final String userName;
  final String userProfilePhoto;
  final String title;
  final String description;
  final DateTime expiryDate;
  final String timeline;
  final ExchangeType exchangeType;

  final String? coverImage;
  final List<String> skillsOffering;
  final int? rewardTimeCoins;
  final List<String> skillsNeeded;
  final String status;
  final int? matchPercentage;
  final String? offerDetails;

  Offer({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfilePhoto,
    required this.title,
    required this.description,
    required this.expiryDate,
    required this.timeline,
    required this.exchangeType,
    this.coverImage,
    this.skillsOffering = const [],
    this.rewardTimeCoins,
    this.skillsNeeded = const [],
    this.status = 'active',
    this.matchPercentage,
    this.offerDetails,
  });

  DateTime get expirationDate => expiryDate;
  List<String> get offers => skillsOffering;
  List<String> get needs => skillsNeeded;
  int? get timecoinCost => rewardTimeCoins;
}
