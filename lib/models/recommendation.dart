import 'package:skilllink/models/exchange_type.dart';

class Recommendation {
  final String id;
  final String name;
  final String profileImage;
  final bool isVerified;
  final double rating;
  final String status;
  final int matchPercentage;
  final bool isTopRated;
  final List<String> offers;
  final List<String> needs;
  final ExchangeType exchangeType;
  final int? timecoinCost;

  Recommendation({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.isVerified,
    required this.rating,
    required this.status,
    required this.matchPercentage,
    this.isTopRated = false,
    required this.offers,
    required this.needs,
    required this.exchangeType,
    this.timecoinCost,
  });
}
