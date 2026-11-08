import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_model.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_parent_model.dart';
import 'package:al_mahhaba_school/features/children/data/models/labeled_value_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_details_entity.dart';

class ChildDetailsModel extends ChildDetailsEntity {
  const ChildDetailsModel({
    required super.child,
    super.studentCode,
    super.dateOfBirth,
    super.age,
    super.gender,
    super.religion,
    super.nationality,
    super.address,
    super.homePhone,
    super.email,
    super.previousSchool,
    super.father,
    super.mother,
    super.guardianName,
    super.enrolledAt,
  });

  /// The child as in the list of children (`student_id`, `name`, `grade`,
  /// `class`…), and: { "student_code": null, "date_of_birth": "2018-06-01",
  /// "age": 8, "gender": { …labeled value… }, "religion": { … },
  /// "nationality": { … }, "address": "…", "home_phone": null,
  /// "email": null, "previous_school": null, "father": { …parent… },
  /// "mother": { … }, "guardian_name": null, "enrolled_at": "2026-01-27" }
  factory ChildDetailsModel.fromJson(Map<String, dynamic> json) =>
      ChildDetailsModel(
        child: ChildModel.fromJson(json),
        studentCode: jsonTextOrNull(json['student_code']),
        dateOfBirth: DateTime.tryParse(json['date_of_birth'] as String? ?? ''),
        age: (json['age'] as num?)?.toInt(),
        gender: LabeledValueModel.maybeFromJson(json['gender']),
        religion: LabeledValueModel.maybeFromJson(json['religion']),
        nationality: LabeledValueModel.maybeFromJson(json['nationality']),
        address: jsonTextOrNull(json['address']),
        homePhone: jsonTextOrNull(json['home_phone']),
        email: jsonTextOrNull(json['email']),
        previousSchool: jsonTextOrNull(json['previous_school']),
        father: ChildParentModel.maybeFromJson(json['father']),
        mother: ChildParentModel.maybeFromJson(json['mother']),
        guardianName: jsonTextOrNull(json['guardian_name']),
        enrolledAt: DateTime.tryParse(json['enrolled_at'] as String? ?? ''),
      );
}
