import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_counts_entity.dart';

class AttendanceCountsModel extends AttendanceCountsEntity {
  const AttendanceCountsModel({
    required super.presentDays,
    required super.absentDays,
    required super.lateDays,
    required super.excusedDays,
  });

  /// { "present": 15, "absent": 1, "late": 1, "excused_or_medical": 0 }
  factory AttendanceCountsModel.fromJson(Map<String, dynamic> json) =>
      AttendanceCountsModel(
        presentDays: json['present'] as int? ?? 0,
        absentDays: json['absent'] as int? ?? 0,
        lateDays: json['late'] as int? ?? 0,
        excusedDays: json['excused_or_medical'] as int? ?? 0,
      );
}
