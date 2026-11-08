import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_activity_entity.dart';

class ResultActivityModel extends ResultActivityEntity {
  const ResultActivityModel({required super.name, super.status});

  /// { "name": "Multi-\ndisciplinary", "status": "اجتاز" }
  factory ResultActivityModel.fromJson(Map<String, dynamic> json) {
    final status = jsonText(json['status']);
    return ResultActivityModel(
      name: jsonText(json['name']),
      status: status.isEmpty ? null : status,
    );
  }
}
