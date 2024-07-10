class BankCardData {
  String cardNumber;
  String userUID;
  String expiryDate;
  String cvv;

  BankCardData({
    required this.cardNumber,
    required this.userUID,
    required this.expiryDate,
    required this.cvv,
  });

  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'userUID': userUID,
        'expiryDate': expiryDate,
        'cvv': cvv,
      };

  static fromJson(Map<String, dynamic> json) {
    return BankCardData(
      cardNumber: json['cardNumber'],
      userUID: json['userUID'],
      expiryDate: json['expiryDate'],
      cvv: json['cvv'],
    );
  }
}