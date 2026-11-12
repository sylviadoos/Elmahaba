// The Home use cases, mocked once for the bloc tests.
// Regenerate with `dart run build_runner build`.
// (mockito reads the annotation on an import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<GetChildDashboardUseCase>(),
  MockSpec<GetMonthAttendanceUseCase>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/attendance/domain/use_cases/get_month_attendance_use_case.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_child_dashboard_use_case.dart';
