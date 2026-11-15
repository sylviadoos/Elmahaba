import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_attendance_entity.dart';

class DashboardAttendanceModel extends DashboardAttendanceEntity {
  const DashboardAttendanceModel({super.todayStatus, super.presentDays});

  /// { "today": "present", "present_days": 3 } — `today` null until it's
  /// taken.
  factory DashboardAttendanceModel.fromJson(Map<String, dynamic> json) =>
      DashboardAttendanceModel(
        // Sent alone, or as {"status": …}.
        todayStatus: switch (json['today']) {
          final String status => status,
          {'status': final String status} => status,
          _ => null,
        },
        presentDays: jsonDouble(json['present_days'])?.toInt() ?? 0,
      );
}
