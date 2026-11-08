import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class AttendanceRepo {
  /// The attendance of the child with this `studentId` in [month] (any day
  /// in it).
  Future<Result<MonthAttendanceEntity>> getMonthAttendance({
    required int childId,
    required DateTime month,
  });
}
