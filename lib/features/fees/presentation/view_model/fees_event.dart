sealed class FeesEvent {
  const FeesEvent();
}

/// Loads a child's fee statement, unless it's already shown or loading.
/// Also "Try again".
final class LoadFeesEvent extends FeesEvent {
  const LoadFeesEvent(this.childId, {this.refresh = false});

  /// The child's `studentId`.
  final int childId;

  /// Loads it again even when it's shown, e.g. after a payment started.
  final bool refresh;
}

/// Adds an optional fee to the child's fees, or drops it again; the
/// statement is loaded again after, as it changes with it.
final class ChangeOptionalFeeEvent extends FeesEvent {
  const ChangeOptionalFeeEvent({
    required this.childId,
    required this.feeId,
    required this.add,
  });

  /// The child's `studentId`.
  final int childId;

  /// The statement line's id.
  final int feeId;

  /// Adds it; false drops it.
  final bool add;
}
