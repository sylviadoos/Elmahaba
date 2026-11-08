sealed class ExcusableAbsencesEvent {
  const ExcusableAbsencesEvent();
}

/// Loads which of a child's absences an excuse can be (or was) sent for.
/// For the child already shown, what's shown stays until the new list
/// arrives (or if it can't).
final class LoadExcusableAbsencesEvent extends ExcusableAbsencesEvent {
  const LoadExcusableAbsencesEvent(this.childId);

  /// The child's `studentId`.
  final int childId;
}
