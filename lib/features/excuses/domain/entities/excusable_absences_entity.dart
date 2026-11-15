import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absence_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_rules_entity.dart';

/// A child's absences that an excuse can be (or was) sent for, and the
/// school's limits for its documents.
class ExcusableAbsencesEntity extends Equatable {
  const ExcusableAbsencesEntity({required this.rules, required this.absences});

  final ExcuseRulesEntity rules;
  final List<ExcusableAbsenceEntity> absences;

  /// The one on [day]'s date, if any.
  ExcusableAbsenceEntity? on(DateTime day) => absences
      .where(
        (absence) =>
            absence.date.year == day.year &&
            absence.date.month == day.month &&
            absence.date.day == day.day,
      )
      .firstOrNull;

  @override
  List<Object?> get props => [rules, absences];
}
