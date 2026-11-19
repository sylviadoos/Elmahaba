import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';

/// Linking a child by a texted code: checking the code, and sending it
/// (the first time when Firebase sends it, and again).
class LinkChildCodeState extends Equatable {
  const LinkChildCodeState({
    this.checking = const BaseState.initial(),
    this.resending = const BaseState.initial(),
    this.nextByFirebase = false,
  });

  /// The code checked: success with the child once it's linked.
  final BaseState<ChildEntity> checking;

  /// A code sent: success with the check — as the school sent it back when
  /// it texted the code (a new count of resends), or as it was when
  /// Firebase sent it.
  final BaseState<LinkVerificationEntity> resending;

  /// Whether asking again has Firebase send the code: after the school's.
  /// Firebase's aren't counted against the school's resends, so it can be
  /// asked for when those are used up.
  final bool nextByFirebase;

  bool get isBusy =>
      checking.state == StateType.loading ||
      resending.state == StateType.loading;

  LinkChildCodeState copyWith({
    BaseState<ChildEntity>? checking,
    BaseState<LinkVerificationEntity>? resending,
    bool? nextByFirebase,
  }) => LinkChildCodeState(
    checking: checking ?? this.checking,
    resending: resending ?? this.resending,
    nextByFirebase: nextByFirebase ?? this.nextByFirebase,
  );

  @override
  List<Object?> get props => [checking, resending, nextByFirebase];
}
