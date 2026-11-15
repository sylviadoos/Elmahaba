/// The `code` of the fees errors the app reacts to.
abstract final class FeesErrorCodes {
  /// Paying an installment before the earlier ones of the same fee.
  static const String payOnlineInstallmentOrder =
      'pay_online_installment_order';

  /// Nothing to pay online right now.
  static const String payOnlineNothingDue = 'pay_online_nothing_due';

  /// The school turned online payment off.
  static const String payOnlineDisabled = 'pay_online_disabled';

  /// Skoolex Pay couldn't start the payment; try again later.
  static const String payOnlineUnavailable = 'pay_online_unavailable';
}
