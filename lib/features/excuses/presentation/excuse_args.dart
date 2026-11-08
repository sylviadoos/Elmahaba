import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absence_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_rules_entity.dart';

/// What "Submit excuse" opens with: the child (`studentId`), the absence
/// and the school's limits for the documents.
class NewExcuseArgs {
  const NewExcuseArgs({
    required this.childId,
    required this.absence,
    required this.rules,
  });

  final int childId;
  final ExcusableAbsenceEntity absence;
  final ExcuseRulesEntity rules;
}

/// What an excuse's page may open with, besides its ids in the path: the
/// excuse as just sent, shown while it loads, and the limits for adding
/// documents (the documented ones when unknown).
class ExcuseDetailsArgs {
  const ExcuseDetailsArgs({this.shown, this.rules});

  final ExcuseDetailsEntity? shown;
  final ExcuseRulesEntity? rules;
}
