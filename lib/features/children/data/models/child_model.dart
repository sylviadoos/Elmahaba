import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';

class ChildModel extends ChildEntity {
  const ChildModel({
    required super.studentId,
    required super.name,
    required super.nameAr,
    required super.nationalId,
    required super.relationship,
    required super.access,
    super.readOnlyUntil,
    super.photoUrl,
    required super.grade,
    required super.className,
    required super.academicYear,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) => ChildModel(
    studentId: json['student_id'] as int,
    name: json['name'] as String,
    nameAr: json['name_ar'] as String? ?? '',
    nationalId: json['national_id'] as String? ?? '',
    relationship: json['relationship'] as String,
    access: json['access'] as String,
    readOnlyUntil: DateTime.tryParse(json['read_only_until'] as String? ?? ''),
    photoUrl: json['photo_url'] as String?,
    grade: json['grade'] as String? ?? '',
    className: json['class'] as String? ?? '',
    academicYear: json['academic_year'] as String? ?? '',
  );

  factory ChildModel.fromEntity(ChildEntity entity) => switch (entity) {
    final ChildModel model => model,
    _ => ChildModel(
      studentId: entity.studentId,
      name: entity.name,
      nameAr: entity.nameAr,
      nationalId: entity.nationalId,
      relationship: entity.relationship,
      access: entity.access,
      readOnlyUntil: entity.readOnlyUntil,
      photoUrl: entity.photoUrl,
      grade: entity.grade,
      className: entity.className,
      academicYear: entity.academicYear,
    ),
  };

  /// The same shape as the API's, so a saved child reads back with
  /// [ChildModel.fromJson].
  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'name': name,
    'name_ar': nameAr,
    'national_id': nationalId,
    'relationship': relationship,
    'access': access,
    'read_only_until': readOnlyUntil?.toIso8601String(),
    'photo_url': photoUrl,
    'grade': grade,
    'class': className,
    'academic_year': academicYear,
  };
}
