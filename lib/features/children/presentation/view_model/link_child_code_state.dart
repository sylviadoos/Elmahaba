import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';

/// Linking a child by the code the school texted: checking the code, and
/// asking for another.
class LinkChildCodeState extends Equatable {
  const LinkChildCodeState({
    this.checking = const BaseState.initial(),
    this.resending = const BaseState.initial(),
  });

  /// The code checked: success with the child once it's linked.
  final BaseState<ChildEntity> checking;

  /// Another code asked for: success with the check as the school sent it
  /// again (a new count of resends).
  final BaseState<LinkVerificationEntity> resending;

  bool get isBusy =>
      checking.state == StateType.loading ||
      resending.state == StateType.loading;

  LinkChildCodeState copyWith({
    BaseState<ChildEntity>? checking,
    BaseState<LinkVerificationEntity>? resending,
  }) => LinkChildCodeState(
    checking: checking ?? this.checking,
    resending: resending ?? this.resending,
  );

  @override
  List<Object?> get props => [checking, resending];
}
