import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';

/// The parent's account after signing up: who they are and their children.
/// The access token isn't here — it's saved, not shown.
class AuthSessionEntity extends Equatable {
  const AuthSessionEntity({
    required this.parent,
    required this.children,
    required this.autoLinked,
    required this.nextScreen,
  });

  final ParentEntity parent;
  final List<ChildEntity> children;

  /// How many children the school linked to the account by itself.
  final int autoLinked;

  /// Where the API says to go next, e.g. "home".
  final String nextScreen;

  @override
  List<Object?> get props => [parent, children, autoLinked, nextScreen];
}
