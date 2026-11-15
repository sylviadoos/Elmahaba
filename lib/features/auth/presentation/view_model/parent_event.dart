sealed class ParentEvent {
  const ParentEvent();
}

/// Shows the parent kept on the phone — at launch, and right after log in,
/// which kept them.
final class ShowSavedParentEvent extends ParentEvent {
  const ShowSavedParentEvent();
}

/// Forgets the parent shown (log out).
final class ClearParentEvent extends ParentEvent {
  const ClearParentEvent();
}
