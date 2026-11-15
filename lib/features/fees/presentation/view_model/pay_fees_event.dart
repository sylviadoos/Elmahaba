sealed class PayFeesEvent {
  const PayFeesEvent();
}

/// Starts paying installments online, unless a start is on its way.
final class PayOnlineEvent extends PayFeesEvent {
  const PayOnlineEvent({required this.childId, required this.payKeys});

  /// The child's `studentId`.
  final int childId;

  /// The installments to pay: their `payKey`.
  final List<String> payKeys;
}
