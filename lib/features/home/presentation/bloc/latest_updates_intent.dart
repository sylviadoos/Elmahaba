/// What happens to Home's latest announcements, homework and results, sent
/// to `LatestUpdatesBloc`.
sealed class LatestUpdatesIntent {
  const LatestUpdatesIntent();
}

/// Shows the latest of the child with [childId] (picked on Home, or the
/// first once the children load). Nothing loads again for the child
/// already shown, except what failed.
final class ShowChildUpdatesIntent extends LatestUpdatesIntent {
  const ShowChildUpdatesIntent(this.childId);

  /// The child's `studentId`.
  final int childId;
}

/// "Try again" on a part that couldn't load: loads what failed again.
final class RetryUpdatesIntent extends LatestUpdatesIntent {
  const RetryUpdatesIntent();
}
