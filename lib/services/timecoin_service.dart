import 'package:skilllink/models/timecoin.dart';

class TimecoinService {
  static final TimecoinService _instance = TimecoinService._internal();
  factory TimecoinService() => _instance;
  static TimecoinService get instance => _instance;

  TimecoinService._internal() {
    _timecoinService = TimecoinServiceModel();
  }

  late TimecoinServiceModel _timecoinService;

  int getBalance() => _timecoinService.getBalance();
  List<TimecoinTransaction> getTransactions() =>
      _timecoinService.getTransactions();
  void earnTimecoins(int amount, String description, {String? relatedUserId}) =>
      _timecoinService.earnTimecoins(
        amount,
        description,
        relatedUserId: relatedUserId,
      );
  bool spendTimecoins(
    int amount,
    String description, {
    String? relatedUserId,
  }) => _timecoinService.spendTimecoins(
    amount,
    description,
    relatedUserId: relatedUserId,
  );
  void purchaseTimecoins(int amount, String purchaseId) =>
      _timecoinService.purchaseTimecoins(amount, purchaseId);
  void reset() => _timecoinService.reset();
}

class TimecoinServiceModel {
  static const int defaultBalance = 10;
  int _balance = defaultBalance;
  final List<TimecoinTransaction> _transactions = [];

  int getBalance() => _balance;

  List<TimecoinTransaction> getTransactions() =>
      List.unmodifiable(_transactions);

  void earnTimecoins(int amount, String description, {String? relatedUserId}) {
    _balance += amount;
    _transactions.add(
      TimecoinTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'earned',
        amount: amount,
        description: description,
        timestamp: DateTime.now(),
        relatedUserId: relatedUserId,
      ),
    );
  }

  bool spendTimecoins(int amount, String description, {String? relatedUserId}) {
    if (_balance >= amount) {
      _balance -= amount;
      _transactions.add(
        TimecoinTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'spent',
          amount: amount,
          description: description,
          timestamp: DateTime.now(),
          relatedUserId: relatedUserId,
        ),
      );
      return true;
    }
    return false;
  }

  void purchaseTimecoins(int amount, String purchaseId) {
    _balance += amount;
    _transactions.add(
      TimecoinTransaction(
        id: purchaseId,
        type: 'purchased',
        amount: amount,
        description: 'Purchased $amount timecoins',
        timestamp: DateTime.now(),
      ),
    );
  }

  void reset() {
    _balance = defaultBalance;
    _transactions.clear();
  }
}
