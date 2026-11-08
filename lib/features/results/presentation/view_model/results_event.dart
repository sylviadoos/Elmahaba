sealed class ResultsEvent {
  const ResultsEvent();
}

/// Loads a child's latest result, unless it's already shown or loading.
/// Also "Try again".
final class LoadLatestResultEvent extends ResultsEvent {
  const LoadLatestResultEvent(this.childId);

  /// The child's `studentId`.
  final int childId;
}
