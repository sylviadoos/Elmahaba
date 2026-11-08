import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_component_entity.dart';

class ResultComponentModel extends ResultComponentEntity {
  const ResultComponentModel({
    required super.name,
    required super.mark,
    required super.max,
  });

  /// { "name": "Oral Tasks", "mark": 10, "max": 10 }
  factory ResultComponentModel.fromJson(Map<String, dynamic> json) =>
      ResultComponentModel(
        name: jsonText(json['name']),
        mark: jsonDouble(json['mark']) ?? 0,
        max: jsonDouble(json['max']) ?? 0,
      );
}
