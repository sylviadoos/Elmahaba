import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/excusable_absence_model.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/excuse_rules_model.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absences_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_rules_entity.dart';

class ExcusableAbsencesModel extends ExcusableAbsencesEntity {
  const ExcusableAbsencesModel({required super.rules, required super.absences});

  /// { "student_id": 345, "rules": { …rules… },
  ///   "absences": [ …absence… ] }
  factory ExcusableAbsencesModel.fromJson(Map<String, dynamic> json) =>
      ExcusableAbsencesModel(
        rules: switch (json['rules']) {
          final Map<String, dynamic> rules => ExcuseRulesModel.fromJson(rules),
          _ => ExcuseRulesEntity.defaults,
        },
        absences: [
          for (final absence in jsonObjects(json['absences']))
            ?ExcusableAbsenceModel.fromJson(absence),
        ],
      );
}
