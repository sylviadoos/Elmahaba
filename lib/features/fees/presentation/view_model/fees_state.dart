import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';

/// The selected child's fee statement, with the optional fee being added
/// to it or dropped from it.
class FeesState extends Equatable {
  const FeesState({
    this.statement = const BaseState.initial(),
    this.changingFeeId,
    this.changeFailed,
  });

  final BaseState<FeeStatementEntity> statement;

  /// The optional fee the school is adding or dropping, by its id; null
  /// while none is. One goes at a time.
  final int? changingFeeId;

  /// Why the last change didn't happen — the fee is already there, or a
  /// payment stops it being dropped. The page says so and it's cleared
  /// when the next change starts.
  final AppException? changeFailed;

  bool get isChanging => changingFeeId != null;

  FeesState copyWith({
    BaseState<FeeStatementEntity>? statement,
    int? Function()? changingFeeId,
    AppException? Function()? changeFailed,
  }) => FeesState(
    statement: statement ?? this.statement,
    changingFeeId: changingFeeId != null ? changingFeeId() : this.changingFeeId,
    changeFailed: changeFailed != null ? changeFailed() : this.changeFailed,
  );

  @override
  List<Object?> get props => [statement, changingFeeId, changeFailed];
}
