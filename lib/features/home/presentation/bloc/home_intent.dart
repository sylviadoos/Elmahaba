/// What happens on Home, sent to `HomeBloc`.
sealed class HomeIntent {
  const HomeIntent();
}

/// Shows the dashboard of the child with [childId]: picked on Home or
/// elsewhere, or the first once the children load. Nothing loads again for
/// the child already shown, unless it failed.
final class ShowChildIntent extends HomeIntent {
  const ShowChildIntent(this.childId);

  /// The child's `studentId`.
  final int childId;
}

/// Asks the school again for the child shown, keeping what's shown until
/// the answer comes: something may have changed (a notification arrived,
/// the parent came back to Home or to the app, or pulled down). After a
/// failure, it's "Try again".
final class RefreshHomeIntent extends HomeIntent {
  const RefreshHomeIntent();
}
