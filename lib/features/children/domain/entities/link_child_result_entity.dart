import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';

/// What happened to a request to link a child.
sealed class LinkChildResultEntity extends Equatable {
  const LinkChildResultEntity();
}

/// The school matched the ID: the child is on the account now.
final class ChildLinked extends LinkChildResultEntity {
  const ChildLinked(this.child);

  final ChildEntity child;

  @override
  List<Object?> get props => [child];
}

/// The school has to confirm it first; the child shows up once it does.
final class ChildLinkPending extends LinkChildResultEntity {
  const ChildLinkPending(this.requestId);

  final int requestId;

  @override
  List<Object?> get props => [requestId];
}
