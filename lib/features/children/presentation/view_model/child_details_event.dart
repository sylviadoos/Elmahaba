sealed class ChildDetailsEvent {
  const ChildDetailsEvent();
}

/// Loads the child [childId] (`studentId`): when the page opens, and on
/// "Try again". With [refresh] (pulling down), what's shown stays until
/// it arrives (or if it can't).
final class LoadChildDetailsEvent extends ChildDetailsEvent {
  const LoadChildDetailsEvent(this.childId, {this.refresh = false});

  final int childId;
  final bool refresh;
}
