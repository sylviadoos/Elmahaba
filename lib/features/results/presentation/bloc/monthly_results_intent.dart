/// What happens to the monthly results on Results, sent to
/// `MonthlyResultsBloc`.
sealed class MonthlyResultsIntent {
  const MonthlyResultsIntent();
}

/// Shows the monthly results of the child with [childId]: picked on
/// Results or elsewhere. Nothing loads again for the child already shown,
/// unless it failed ("Try again").
final class ShowChildMonthlyIntent extends MonthlyResultsIntent {
  const ShowChildMonthlyIntent(this.childId);

  /// The child's `studentId`.
  final int childId;
}

/// Shows the month filed under [key] ("m0").
final class SelectMonthIntent extends MonthlyResultsIntent {
  const SelectMonthIntent(this.key);

  final String key;
}
