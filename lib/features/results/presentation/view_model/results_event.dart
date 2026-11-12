sealed class ResultsEvent {
  const ResultsEvent();
}

/// Loads a child's results, unless they're already shown or loading. Also
/// "Try again".
final class LoadResultsEvent extends ResultsEvent {
  const LoadResultsEvent(this.childId);

  /// The child's `studentId`.
  final int childId;
}

/// Shows the result with this id: a month or a term picked in the filter.
final class SelectResultEvent extends ResultsEvent {
  const SelectResultEvent(this.resultId);

  final int resultId;
}
