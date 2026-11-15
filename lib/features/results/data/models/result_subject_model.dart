import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_component_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_subject_entity.dart';

class ResultSubjectModel extends ResultSubjectEntity {
  const ResultSubjectModel({
    required super.name,
    required super.total,
    required super.maxTotal,
    required super.components,
    super.initialAssessment,
    super.finalAssessment,
    super.status,
  });

  /// { "name": "Math", "included_in_total": true, "components": [...],
  ///   "total": 96, "max_total": 100, "initial_assessment": "F",
  ///   "final_assessment": "F", "status": null }
  ///
  /// `included_in_total` is read by the result, which files it.
  factory ResultSubjectModel.fromJson(Map<String, dynamic> json) {
    final components = [
      for (final component in jsonObjects(json['components']))
        ResultComponentModel.fromJson(component),
    ];
    final givenMax = jsonDouble(json['max_total']) ?? 0;
    final partsMax = components.fold<double>(0, (sum, c) => sum + c.max);

    return ResultSubjectModel(
      name: jsonText(json['name']),
      total:
          jsonDouble(json['total']) ??
          components.fold<double>(0, (sum, c) => sum + c.mark),
      // Without one: what its parts add up to, else out of 100.
      maxTotal: givenMax > 0 ? givenMax : (partsMax > 0 ? partsMax : 100),
      components: components,
      initialAssessment: _optional(json['initial_assessment']),
      finalAssessment: _optional(json['final_assessment']),
      status: _optional(json['status']),
    );
  }

  static String? _optional(Object? value) {
    final text = jsonText(value);
    return text.isEmpty ? null : text;
  }
}
