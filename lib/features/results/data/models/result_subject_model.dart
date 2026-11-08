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

  /// { "subject": "Arabic", "total": 100, "maxTotal": 100,
  ///   "components": [...], "initialAssessment": "اجتاز", … }
  factory ResultSubjectModel.fromJson(Map<String, dynamic> json) {
    final components = [
      for (final component in jsonObjects(json['components']))
        ResultComponentModel.fromJson(component),
    ];
    final givenMax = jsonDouble(json['maxTotal']) ?? 0;
    final partsMax = components.fold<double>(0, (sum, c) => sum + c.max);

    return ResultSubjectModel(
      name: jsonText(json['subject']),
      total: jsonDouble(json['total']) ?? 0,
      // Without one: what its parts add up to, else out of 100.
      maxTotal: givenMax > 0 ? givenMax : (partsMax > 0 ? partsMax : 100),
      components: components,
      initialAssessment: _optional(json['initialAssessment']),
      finalAssessment: _optional(json['finalAssessment']),
      status: _optional(json['status']),
    );
  }

  static String? _optional(Object? value) {
    final text = jsonText(value);
    return text.isEmpty ? null : text;
  }
}
