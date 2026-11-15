import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

extension ChildrenContext on BuildContext {
  /// The parent's children, from the app's shared [ChildrenViewModel].
  /// Rebuilds the caller when they change; empty until they load.
  List<ChildEntity> watchChildren() =>
      select<ChildrenViewModel, List<ChildEntity>?>(
        (viewModel) => viewModel.state.children.data,
      ) ??
      const [];

  /// The place of the child every page shows
  /// ([ChildrenState.selectedIndex]); rebuilds the caller when it changes.
  int watchSelectedChildIndex() => select<ChildrenViewModel, int>(
    (viewModel) => viewModel.state.selectedIndex,
  );

  /// Shows the child with [studentId] on every page.
  void selectChild(int studentId) =>
      read<ChildrenViewModel>().doAction(SelectChildEvent(studentId));
}

extension ChildSelection on List<ChildEntity> {
  /// [index] kept inside the list, which can get shorter after a refresh.
  int clampSelection(int index) => isEmpty ? 0 : math.min(index, length - 1);
}

extension SelectedChildChange on ChildrenState {
  /// Another child to show than in [previous]: one was picked, or the list
  /// changed under it.
  bool showsOtherChildThan(ChildrenState previous) =>
      selectedChild?.studentId != previous.selectedChild?.studentId;
}
