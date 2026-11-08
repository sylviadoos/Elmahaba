sealed class HomeEvent {
  const HomeEvent();
}

/// Loads a child's dashboard, unless it's already shown or loading. Also
/// "Try again".
final class LoadDashboardEvent extends HomeEvent {
  const LoadDashboardEvent(this.childId);

  /// The child's `studentId`.
  final int childId;
}
