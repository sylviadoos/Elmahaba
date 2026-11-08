import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/attendance/domain/use_cases/get_month_attendance_use_case.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/view_model/attendance_event.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/view_model/attendance_state.dart';

/// The selected child's attendance in the month shown. One per Attendance
/// page. No navigation actions, hence `void`.
@injectable
class AttendanceViewModel
    extends BaseCubit<AttendanceState, AttendanceEvent, void> {
  AttendanceViewModel(this._getMonthAttendance)
    : super(const BaseState.initial());

  final GetMonthAttendanceUseCase _getMonthAttendance;

  /// The child and month shown or loading.
  (int, DateTime)? _shown;

  @override
  Future<void> doAction(AttendanceEvent event) async {
    switch (event) {
      case LoadAttendanceEvent(:final childId, :final month):
        await _load(childId, month);
    }
  }

  Future<void> _load(int childId, DateTime month) async {
    final request = (childId, month);
    if (request == _shown && state.state != StateType.error) return;
    _shown = request;
    emit(const BaseState.loading());
    final result = await _getMonthAttendance(childId: childId, month: month);
    // Another child or month was picked meanwhile: that one's on its way.
    if (isClosed || request != _shown) return;
    result.when(
      success: (attendance) => emit(BaseState.success(attendance)),
      failure: (exception) => emit(BaseState.error(exception)),
    );
  }
}
