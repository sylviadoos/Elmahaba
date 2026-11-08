import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';

/// Two things at once, so the list stays on screen while a child is linked;
/// and the child picked, which every page shows.
class ChildrenState extends Equatable {
  const ChildrenState({
    this.children = const BaseState.initial(),
    this.link = const BaseState.initial(),
    this.selectedId,
  });

  /// The children on the parent's account.
  final BaseState<List<ChildEntity>> children;

  /// The last "link a child" request: [ChildLinked] or [ChildLinkPending].
  final BaseState<LinkChildResultEntity> link;

  /// The `studentId` of the child picked in a header; null before one is.
  final int? selectedId;

  /// The child every page shows: the one picked, or the first while none
  /// is (or once it's unlinked); null without children.
  ChildEntity? get selectedChild {
    final list = children.data ?? const <ChildEntity>[];
    return list.where((child) => child.studentId == selectedId).firstOrNull ??
        list.firstOrNull;
  }

  /// [selectedChild]'s place in the list; 0 without children.
  int get selectedIndex {
    final list = children.data ?? const <ChildEntity>[];
    final index = list.indexWhere((child) => child.studentId == selectedId);
    return index < 0 ? 0 : index;
  }

  ChildrenState copyWith({
    BaseState<List<ChildEntity>>? children,
    BaseState<LinkChildResultEntity>? link,
    int? Function()? selectedId,
  }) => ChildrenState(
    children: children ?? this.children,
    link: link ?? this.link,
    selectedId: selectedId != null ? selectedId() : this.selectedId,
  );

  @override
  List<Object?> get props => [children, link, selectedId];
}
