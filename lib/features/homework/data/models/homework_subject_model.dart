import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_subject_entity.dart';

class HomeworkSubjectModel extends HomeworkSubjectEntity {
  const HomeworkSubjectModel({required super.id, required super.name});

  /// { "id": 3, "name": "Math" }
  factory HomeworkSubjectModel.fromJson(Map<String, dynamic> json) =>
      HomeworkSubjectModel(
        id: json['id'] as int? ?? 0,
        name: jsonText(json['name']),
      );
}
