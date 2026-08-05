enum PaymentMethod { click, payme, uzumBank, visa, mastercard, applePay, googlePay, cash }

extension PaymentMethodX on PaymentMethod {
  String get apiValue {
    switch (this) {
      case PaymentMethod.uzumBank:
        return 'uzum_bank';
      case PaymentMethod.applePay:
        return 'apple_pay';
      case PaymentMethod.googlePay:
        return 'google_pay';
      default:
        return name;
    }
  }

  String get displayNameUz {
    switch (this) {
      case PaymentMethod.click:
        return 'Click';
      case PaymentMethod.payme:
        return 'Payme';
      case PaymentMethod.uzumBank:
        return 'Uzum Bank';
      case PaymentMethod.visa:
        return 'Visa';
      case PaymentMethod.mastercard:
        return 'Mastercard';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.cash:
        return 'Naqd pul';
    }
  }

  bool get requiresRedirect => this != PaymentMethod.cash;
}
