import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_request_entity.dart';

sealed class ChildrenEvent {
  const ChildrenEvent();
}

/// Shows the saved children at once, then refreshes them from the API —
/// quietly if they're already on screen. Also "Try again".
final class LoadChildrenEvent extends ChildrenEvent {
  const LoadChildrenEvent();
}

/// Shows the saved children without calling the API — right after log in,
/// which saved them.
final class ShowSavedChildrenEvent extends ChildrenEvent {
  const ShowSavedChildrenEvent();
}

/// Shows the child with [studentId] on every page: picked in any header.
final class SelectChildEvent extends ChildrenEvent {
  const SelectChildEvent(this.studentId);

  final int studentId;
}

/// Forgets the children shown (log out).
final class ClearChildrenEvent extends ChildrenEvent {
  const ClearChildrenEvent();
}

/// Links the child whose national ID the parent typed.
final class LinkChildEvent extends ChildrenEvent {
  const LinkChildEvent(this.request);

  final LinkChildRequestEntity request;
}

/// The parent entered the code the school texted for [child]: it's linked,
/// so it shows everywhere, and the list is asked for again.
final class ChildLinkVerifiedEvent extends ChildrenEvent {
  const ChildLinkVerifiedEvent(this.child);

  final ChildEntity child;
}
