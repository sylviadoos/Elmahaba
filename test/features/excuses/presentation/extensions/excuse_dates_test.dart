import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absence_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absences_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_rules_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_status.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_summary_entity.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/extensions/excuse_dates.dart';

/// The absence on [day] of November 2026, with an excuse in [status] (none
/// when null).
ExcusableAbsenceEntity _absence(int day, ExcuseStatus? status) =>
    ExcusableAbsenceEntity(
      attendanceId: day,
      // As the API may send it: with a time of day.
      date: DateTime(2026, 11, day, 9, 30),
      canSubmit: status == null,
      excuse: status == null
          ? null
          : ExcuseSummaryEntity(id: day, status: status),
    );

void main() {
  test('every day an excuse was sent for, at midnight; not one without', () {
    const rules = ExcuseRulesEntity(
      windowDays: 3,
      maxDocuments: 5,
      allowedTypes: ['pdf'],
      maxFileMegabytes: 10,
    );
    final absences = ExcusableAbsencesEntity(
      rules: rules,
      absences: [
        _absence(2, ExcuseStatus.submitted),
        _absence(3, ExcuseStatus.accepted),
        _absence(4, ExcuseStatus.rejected),
        _absence(5, null),
      ],
    );

    expect(absences.excuseDates, {
      DateTime(2026, 11, 2),
      DateTime(2026, 11, 3),
      DateTime(2026, 11, 4),
    });
  });
}
