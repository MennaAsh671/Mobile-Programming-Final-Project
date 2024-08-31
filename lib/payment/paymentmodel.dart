class CreditCardDetails {
  final String cardNumber;
  final String expirationDate;
  final String cvv;

  CreditCardDetails({
    required this.cardNumber,
    required this.expirationDate,
    required this.cvv,
  });

  // Convert credit card details to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber,
      'expirationDate': expirationDate,
      'cvv': cvv,
    };
  }

  // Create CreditCardDetails object from Firestore data
  factory CreditCardDetails.fromMap(Map<String, dynamic> map) {
    return CreditCardDetails(
      cardNumber: map['cardNumber'],
      expirationDate: map['expirationDate'],
      cvv: map['cvv'],
    );
  }
}