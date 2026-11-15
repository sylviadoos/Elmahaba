import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_details_entity.dart';

class ChildDetailsState extends Equatable {
  const ChildDetailsState({this.details = const BaseState.initial()});

  final BaseState<ChildDetailsEntity> details;

  ChildDetailsState copyWith({BaseState<ChildDetailsEntity>? details}) =>
      ChildDetailsState(details: details ?? this.details);

  @override
  List<Object?> get props => [details];
}
