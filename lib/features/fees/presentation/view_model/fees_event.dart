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
