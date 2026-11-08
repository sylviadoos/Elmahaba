import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_student_entity.dart';

class FeeStudentModel extends FeeStudentEntity {
  const FeeStudentModel({
    required super.id,
    required super.name,
    required super.nameEn,
    required super.nameAr,
    required super.nationalId,
    required super.grade,
    required super.academicYear,
  });

  /// { "name": "…", "name_en": "…", "name_ar": "…",
  ///   "national_id": "31806012500923", "grade": "Second Primary",
  ///   "academic_year": "2026-2027" }, with [id] sent next to it
  /// (`student_id`).
  factory FeeStudentModel.fromJson(
    Map<String, dynamic> json, {
    required int id,
  }) => FeeStudentModel(
    id: id,
    name: jsonText(json['name']),
    nameEn: jsonText(json['name_en']),
    nameAr: jsonText(json['name_ar']),
    nationalId: '${json['national_id'] ?? ''}',
    grade: jsonText(json['grade']),
    academicYear: jsonText(json['academic_year']),
  );
}
