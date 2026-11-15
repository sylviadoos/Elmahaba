import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absences_entity.dart';

extension ExcuseDates on ExcusableAbsencesEntity {
  /// The days an excuse was sent for, whatever came of it, at midnight:
  /// on the calendar, an absence with one shows as excused.
  Set<DateTime> get excuseDates => {
    for (final absence in absences)
      if (absence.excuse != null)
        DateTime(absence.date.year, absence.date.month, absence.date.day),
  };
}
