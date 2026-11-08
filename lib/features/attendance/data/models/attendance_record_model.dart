import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_record_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_status.dart';

class AttendanceRecordModel extends AttendanceRecordEntity {
  const AttendanceRecordModel({
    required super.date,
    required super.status,
    super.reason,
  });

  /// { "date": "2026-10-26", "status": "absent", "reason": "sick" }; null
  /// without a readable date.
  ///
  /// An excused day and a medical leave are counted together
  /// (`excused_or_medical`), and shown alike.
  static AttendanceRecordModel? fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['date'] as String? ?? '');
    if (date == null) return null;
    final reason = jsonText(json['reason']);

    return AttendanceRecordModel(
      date: date,
      status: switch (json['status']) {
        'present' => AttendanceStatus.present,
        'absent' => AttendanceStatus.absent,
        'late' => AttendanceStatus.late,
        'excused' ||
        'medical_leave' ||
        'excused_or_medical' => AttendanceStatus.excused,
        _ => AttendanceStatus.unknown,
      },
      reason: reason.isEmpty ? null : reason,
    );
  }
}
