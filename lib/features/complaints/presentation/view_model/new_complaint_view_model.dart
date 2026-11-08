import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/get_complaint_categories_use_case.dart';
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/send_complaint_use_case.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/new_complaint_event.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/new_complaint_state.dart';

/// Drives the New complaint form. One per page. No navigation actions,
/// hence `void`.
@injectable
class NewComplaintViewModel
    extends BaseCubit<NewComplaintState, NewComplaintEvent, void> {
  NewComplaintViewModel(this._getCategories, this._sendComplaint)
    : super(const NewComplaintState());

  final GetComplaintCategoriesUseCase _getCategories;
  final SendComplaintUseCase _sendComplaint;

  /// The complaint being written. Kept when sending fails, so sending it
  /// again can't file it twice.
  final String _clientUuid = const Uuid().v4();

  @override
  Future<void> doAction(NewComplaintEvent event) async {
    switch (event) {
      case LoadComplaintCategoriesEvent():
        await _loadCategories();
      case SendComplaintEvent():
        await _send(event);
    }
  }

  Future<void> _loadCategories() async {
    if (state.categories.state == StateType.loading) return;
    emit(state.copyWith(categories: const BaseState.loading()));
    final result = await _getCategories();
    if (isClosed) return;
    result.when(
      success: (categories) =>
          emit(state.copyWith(categories: BaseState.success(categories))),
      failure: (exception) =>
          emit(state.copyWith(categories: BaseState.error(exception))),
    );
  }

  Future<void> _send(SendComplaintEvent event) async {
    if (state.sending.state == StateType.loading) return;
    emit(
      state.copyWith(sending: const BaseState.loading(), upload: () => null),
    );
    final result = await _sendComplaint(
      NewComplaintEntity(
        categoryId: event.categoryId,
        studentId: event.studentId,
        description: event.description,
        attachments: event.attachments,
        clientUuid: _clientUuid,
      ),
      onProgress: _onProgress,
    );
    if (isClosed) return;
    result.when(
      success: (complaint) => emit(
        state.copyWith(
          sending: BaseState.success(complaint),
          upload: () => null,
        ),
      ),
      failure: (exception) => emit(
        state.copyWith(sending: BaseState.error(exception), upload: () => null),
      ),
    );
  }

  void _onProgress(int sent, int total) {
    if (isClosed || !state.upload.isStepTo(sent, total)) return;
    emit(state.copyWith(upload: () => (sent: sent, total: total)));
  }
}
