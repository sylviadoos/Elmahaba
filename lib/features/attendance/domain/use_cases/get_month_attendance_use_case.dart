import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/repos/attendance_repo.dart';

/// A child's attendance in a month:
/// `final result = await getMonthAttendance(childId: id, month: month);`
@lazySingleton
class GetMonthAttendanceUseCase {
  GetMonthAttendanceUseCase(this._repo);

  final AttendanceRepo _repo;

  Future<Result<MonthAttendanceEntity>> call({
    required int childId,
    required DateTime month,
  }) => _repo.getMonthAttendance(childId: childId, month: month);
}
