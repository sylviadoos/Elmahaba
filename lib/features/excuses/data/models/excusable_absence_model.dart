import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/excuse_json.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/excuse_summary_model.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absence_entity.dart';

class ExcusableAbsenceModel extends ExcusableAbsenceEntity {
  const ExcusableAbsenceModel({
    required super.attendanceId,
    required super.date,
    super.absenceReason,
    required super.canSubmit,
    super.ineligibleReason,
    super.submitUntil,
    super.excuse,
  });

  /// { "attendance_id": 9120, "student_id": 345, "date": "2026-11-04",
  ///   "status": "absent", "absence_reason": "flu", "can_submit": true,
  ///   "ineligible_reason": null, "submit_until": "2026-11-07",
  ///   "excuse": null }; null without a date.
  static ExcusableAbsenceModel? fromJson(Map<String, dynamic> json) {
    final date = excuseDateFromJson(json['date']);
    if (date == null) return null;
    final reason = jsonText(json['absence_reason']);

    return ExcusableAbsenceModel(
      attendanceId: json['attendance_id'] as int? ?? 0,
      date: date,
      absenceReason: reason.isEmpty ? null : reason,
      canSubmit: json['can_submit'] as bool? ?? false,
      ineligibleReason: excuseIneligibleReasonFromJson(
        json['ineligible_reason'],
      ),
      submitUntil: excuseDateFromJson(json['submit_until']),
      excuse: switch (json['excuse']) {
        final Map<String, dynamic> excuse => ExcuseSummaryModel.fromJson(
          excuse,
        ),
        _ => null,
      },
    );
  }
}
