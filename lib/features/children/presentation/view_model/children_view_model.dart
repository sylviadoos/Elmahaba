import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_request_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/get_children_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/get_saved_children_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/get_selected_child_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/link_child_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/save_selected_child_use_case.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';

/// The parent's children for the whole app: one instance, provided above the
/// router (see `app.dart`), so every header shows the same list and the
/// same child, and a linked child appears everywhere at once. No navigation
/// actions, hence `void`.
@injectable
class ChildrenViewModel extends BaseCubit<ChildrenState, ChildrenEvent, void> {
  ChildrenViewModel(
    this._getSavedChildren,
    this._getChildren,
    this._linkChild,
    this._getSelectedChild,
    this._saveSelectedChild,
  ) : super(const ChildrenState());

  final GetSavedChildrenUseCase _getSavedChildren;
  final GetChildrenUseCase _getChildren;
  final LinkChildUseCase _linkChild;

  /// The child picked, kept across launches: closing the app and opening it
  /// again shows the same one.
  final GetSelectedChildUseCase _getSelectedChild;
  final SaveSelectedChildUseCase _saveSelectedChild;

  /// The API call in flight, so loads asked at once share it.
  Future<void>? _refreshing;

  @override
  Future<void> doAction(ChildrenEvent event) async {
    switch (event) {
      case LoadChildrenEvent():
        await _restoreSelected();
        await _showSaved(onlyIfEmpty: true);
        await _refresh();
      case ShowSavedChildrenEvent():
        await _restoreSelected();
        await _showSaved(onlyIfEmpty: false);
      case SelectChildEvent(:final studentId):
        emit(state.copyWith(selectedId: () => studentId));
        unawaited(_keepSelected(studentId));
      case ClearChildrenEvent():
        emit(const ChildrenState());
      case LinkChildEvent(:final request):
        await _link(request);
      case ChildLinkVerifiedEvent(:final child):
        await _verified(child);
    }
  }

  /// The child picked before the app was closed, before the list shows, so
  /// every page opens on them. One picked since (a notification tapped)
  /// stands; one no longer on the account shows the first instead.
  Future<void> _restoreSelected() async {
    if (state.selectedId != null) return;
    final saved = await _getSelectedChild();
    if (isClosed || saved == null || state.selectedId != null) return;
    emit(state.copyWith(selectedId: () => saved));
  }

  /// Only remembered: if the phone can't keep it, the first child shows
  /// next time, as before one was ever picked.
  Future<void> _keepSelected(int studentId) async {
    try {
      await _saveSelectedChild(studentId);
    } catch (error) {
      debugPrint('Keeping the child picked: $error');
    }
  }

  Future<void> _showSaved({required bool onlyIfEmpty}) async {
    if (onlyIfEmpty && state.children.data != null) return;
    final saved = await _getSavedChildren();
    if (isClosed) return;
    // None saved before a refresh: wait for the API rather than say "none".
    // Right after log in, which saved them, none means none.
    if (saved.isEmpty && onlyIfEmpty) return;
    emit(state.copyWith(children: BaseState.success(saved)));
  }

  Future<void> _refresh() =>
      _refreshing ??= _fetch().whenComplete(() => _refreshing = null);

  Future<void> _fetch() async {
    // A list on screen stays while it refreshes.
    if (state.children.data == null) {
      emit(state.copyWith(children: const BaseState.loading()));
    }
    final result = await _getChildren();
    if (isClosed) return;
    result.when(
      success: (children) =>
          emit(state.copyWith(children: BaseState.success(children))),
      failure: (exception) {
        // Offline with a saved list: keep showing it.
        if (state.children.data != null) return;
        emit(state.copyWith(children: BaseState.error(exception)));
      },
    );
  }

  Future<void> _link(LinkChildRequestEntity request) async {
    if (state.link.state == StateType.loading) return;
    emit(state.copyWith(link: const BaseState.loading()));
    final result = await _linkChild(request);
    if (isClosed) return;
    result.when(
      success: (link) {
        final children = state.children.data;
        emit(
          state.copyWith(
            link: BaseState.success(link),
            // Shown right away, without loading the list again.
            children: link is ChildLinked && children != null
                ? BaseState.success(_withChild(children, link.child))
                : null,
          ),
        );
        // The list never loaded: load it now that it has the new child.
        if (link is ChildLinked && children == null) unawaited(_refresh());
      },
      failure: (exception) =>
          emit(state.copyWith(link: BaseState.error(exception))),
    );
  }

  /// Linked by the code the school texted: as a link done at once, then
  /// the list from the API (and Home with it).
  Future<void> _verified(ChildEntity child) async {
    final children = state.children.data;
    emit(
      state.copyWith(
        link: BaseState.success(ChildLinked(child)),
        children: children == null
            ? null
            : BaseState.success(_withChild(children, child)),
      ),
    );
    await _refresh();
  }

  static List<ChildEntity> _withChild(
    List<ChildEntity> children,
    ChildEntity child,
  ) => [
    for (final other in children)
      if (other.studentId != child.studentId) other,
    child,
  ];
}
