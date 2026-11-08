import 'package:al_mahhaba_school/features/attendance/data/models/attendance_counts_model.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_attendance_entity.dart';

class DashboardAttendanceModel extends DashboardAttendanceEntity {
  const DashboardAttendanceModel({
    super.todayStatus,
    required super.monthCounts,
  });

  factory DashboardAttendanceModel.fromJson(Map<String, dynamic> json) =>
      DashboardAttendanceModel(
        // TODO: confirm `today`'s shape with the API — it's only been null
        // so far. Read as a status, sent alone or as {"status": …}.
        todayStatus: switch (json['today']) {
          final String status => status,
          {'status': final String status} => status,
          _ => null,
        },
        monthCounts: AttendanceCountsModel.fromJson(
          json['month_counts'] as Map<String, dynamic>? ?? const {},
        ),
      );
}
