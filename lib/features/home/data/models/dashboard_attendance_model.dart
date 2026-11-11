import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_attendance_entity.dart';

class DashboardAttendanceModel extends DashboardAttendanceEntity {
  const DashboardAttendanceModel({
    super.todayStatus,
    super.allowedAbsenceDays,
    super.actualAbsenceDays,
    super.remainingAbsenceDays,
    super.exceededAbsenceDays,
  });

  /// { "today": "absent", "allowed_absence_days": 4,
  ///   "actual_absence_days": 1, "remaining_absence_days": 3,
  ///   "exceeded_absence_days": 0 } — `today` null until it's taken.
  factory DashboardAttendanceModel.fromJson(Map<String, dynamic> json) =>
      DashboardAttendanceModel(
        // Sent alone, or as {"status": …}.
        todayStatus: switch (json['today']) {
          final String status => status,
          {'status': final String status} => status,
          _ => null,
        },
        allowedAbsenceDays: json['allowed_absence_days'] as int? ?? 0,
        actualAbsenceDays: json['actual_absence_days'] as int? ?? 0,
        remainingAbsenceDays: json['remaining_absence_days'] as int? ?? 0,
        exceededAbsenceDays: json['exceeded_absence_days'] as int? ?? 0,
      );
}
