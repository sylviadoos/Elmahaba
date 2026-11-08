import 'package:al_mahhaba_school/features/attendance/data/models/month_attendance_model.dart';

/// Talks to the school system's attendance endpoint (signed in). Throws an
/// `AppException` on failure.
abstract interface class AttendanceRemoteDataSource {
  /// The child's attendance in [month] (any day in it): the counts, the
  /// days that weren't a plain "present", and the holidays. [childId] is
  /// the child's `student_id`.
  Future<MonthAttendanceModel> getMonthAttendance({
    required int childId,
    required DateTime month,
  });
}
