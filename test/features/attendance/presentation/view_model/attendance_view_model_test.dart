import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_counts_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/view_model/attendance_event.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/view_model/attendance_state.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/view_model/attendance_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../attendance_mocks.mocks.dart';

final november = DateTime(2026, 11);

MonthAttendanceEntity _month({required int absent, required int excused}) =>
    MonthAttendanceEntity(
      month: november,
      counts: AttendanceCountsEntity(
        presentDays: 6,
        absentDays: absent,
        excusedDays: excused,
      ),
      records: const [],
      holidays: const [],
      weekendWeekdays: const {DateTime.friday, DateTime.saturday},
    );

void main() {
  late MockGetMonthAttendanceUseCase getMonth;

  final absent = _month(absent: 1, excused: 0);
  // The school accepted the excuse: the absence is excused now.
  final excused = _month(absent: 0, excused: 1);

  setUpAll(() => provideResultDummy<MonthAttendanceEntity>());

  setUp(() => getMonth = MockGetMonthAttendanceUseCase());

  AttendanceViewModel build() => AttendanceViewModel(getMonth);

  void answer(List<Result<MonthAttendanceEntity>> answers) {
    var call = 0;
    when(
      getMonth(childId: 1, month: november),
    ).thenAnswer((_) async => answers[call++]);
  }

  Future<void> load(AttendanceViewModel viewModel) =>
      viewModel.doAction(LoadAttendanceEvent(childId: 1, month: november));

  blocTest<AttendanceViewModel, AttendanceState>(
    'the same month again: not asked again',
    setUp: () => answer([Success(data: absent)]),
    build: build,
    act: (viewModel) async {
      await load(viewModel);
      await load(viewModel);
    },
    expect: () => [
      const AttendanceState.loading(),
      AttendanceState.success(absent),
    ],
    verify: (_) => verify(getMonth(childId: 1, month: november)).called(1),
  );

  blocTest<AttendanceViewModel, AttendanceState>(
    'refreshed: the month changes without the skeleton',
    setUp: () => answer([Success(data: absent), Success(data: excused)]),
    build: build,
    act: (viewModel) async {
      await load(viewModel);
      await viewModel.doAction(const RefreshAttendanceEvent());
    },
    expect: () => [
      const AttendanceState.loading(),
      AttendanceState.success(absent),
      AttendanceState.success(excused),
    ],
  );

  blocTest<AttendanceViewModel, AttendanceState>(
    'a refresh that fails: what\'s shown stays, quietly',
    setUp: () => answer([
      Success(data: absent),
      const Failure(exception: NetworkException()),
    ]),
    build: build,
    act: (viewModel) async {
      await load(viewModel);
      await viewModel.doAction(const RefreshAttendanceEvent());
    },
    expect: () => [
      const AttendanceState.loading(),
      AttendanceState.success(absent),
    ],
  );

  blocTest<AttendanceViewModel, AttendanceState>(
    'couldn\'t load: a refresh is "Try again"',
    setUp: () => answer([
      const Failure(exception: NetworkException()),
      Success(data: absent),
    ]),
    build: build,
    act: (viewModel) async {
      await load(viewModel);
      await viewModel.doAction(const RefreshAttendanceEvent());
    },
    expect: () => [
      const AttendanceState.loading(),
      const AttendanceState.error(NetworkException()),
      const AttendanceState.loading(),
      AttendanceState.success(absent),
    ],
  );

  blocTest<AttendanceViewModel, AttendanceState>(
    'nothing shown yet: nothing to refresh',
    build: build,
    act: (viewModel) => viewModel.doAction(const RefreshAttendanceEvent()),
    expect: () => <AttendanceState>[],
    verify: (_) => verifyZeroInteractions(getMonth),
  );
}
