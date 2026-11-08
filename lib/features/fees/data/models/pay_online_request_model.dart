/// The body of `POST …/fees/pay-online`.
class PayOnlineRequestModel {
  const PayOnlineRequestModel({required this.payKeys});

  /// The installments to pay: their `pay_key`.
  final List<String> payKeys;

  /// { "installments": ["…pay_key…"] }
  Map<String, dynamic> toJson() => {'installments': payKeys};
}
