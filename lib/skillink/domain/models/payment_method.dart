enum PaymentMethod {
  cash,
  inApp;

  String get displayName => switch (this) {
        PaymentMethod.cash => 'Cash on Completion',
        PaymentMethod.inApp => 'Pay in-app',
      };
}
