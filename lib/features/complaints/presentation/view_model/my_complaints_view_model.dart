import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/get_complaints_use_case.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/my_complaints_event.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/my_complaints_state.dart';

/// The parent's complaints, a page at a time, for Complaints. One per page.
/// No navigation actions, hence `void`.
@injectable
class MyComplaintsViewModel
    extends BaseCubit<MyComplaintsState, MyComplaintsEvent, void> {
  MyComplaintsViewModel(this._getComplaints) : super(const BaseState.initial());

  final GetComplaintsUseCase _getComplaints;

  @override
  Future<void> doAction(MyComplaintsEvent event) async {
    switch (event) {
      case LoadComplaintsEvent(:final refresh):
        await _load(refresh: refresh);
      case LoadMoreComplaintsEvent():
        await _loadMore();
    }
  }

  Future<void> _load({required bool refresh}) async {
    if (state.state == StateType.loading) return;
    final shown = refresh ? state.data : null;
    if (shown == null) emit(const BaseState.loading());
    final result = await _getComplaints(page: 1);
    if (isClosed) return;
    result.when(
      success: (complaints) => emit(BaseState.success(complaints)),
      failure: (exception) {
        // Refreshing: keep showing them.
        if (shown == null) emit(BaseState.error(exception));
      },
    );
  }

  Future<void> _loadMore() async {
    final loaded = state.data;
    if (loaded == null ||
        !loaded.hasMore ||
        state.state == StateType.moreLoading) {
      return;
    }
    emit(
      BaseState.all(
        state: StateType.moreLoading,
        data: loaded,
        exception: null,
      ),
    );
    final result = await _getComplaints(page: loaded.page + 1);
    // Closed, or loaded again from the start meanwhile.
    if (isClosed || state.data != loaded) return;
    result.when(
      success: (next) => emit(BaseState.success(loaded.followedBy(next))),
      failure: (exception) => emit(
        BaseState.all(
          state: StateType.error,
          data: loaded,
          exception: exception,
        ),
      ),
    );
  }
}
