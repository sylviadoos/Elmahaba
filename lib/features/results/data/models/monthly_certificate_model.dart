import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/data/models/certificate_month_model.dart';
import 'package:al_mahhaba_school/features/results/data/models/certificate_subject_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';

class MonthlyCertificateModel extends MonthlyCertificateEntity {
  const MonthlyCertificateModel({
    required super.studentName,
    required super.studentNameAr,
    required super.grade,
    required super.className,
    required super.academicYear,
    super.months,
    super.subjects,
  });

  /// { "student": { "student_id": 146, "name": "Omar Ahmed",
  ///   "name_ar": "عمر أحمد", "grade": "First Primary", "class": "A",
  ///   "academic_year": "2026-2027" }, "months": [ … ],
  ///   "subjects": [ … ], "pdf_url": "…", "pdf_url_expires_in_minutes": 30 }
  factory MonthlyCertificateModel.fromJson(Map<String, dynamic> json) {
    final student = switch (json['student']) {
      final Map<String, dynamic> student => student,
      _ => const <String, dynamic>{},
    };

    return MonthlyCertificateModel(
      studentName: jsonText(student['name']),
      studentNameAr: jsonText(student['name_ar']),
      grade: jsonText(student['grade']),
      className: jsonText(student['class']),
      academicYear: jsonText(student['academic_year']),
      months: [
        for (final month in jsonObjects(json['months']))
          // Without its key, its marks can't be found.
          if (jsonTextOrNull(month['key']) != null)
            CertificateMonthModel.fromJson(month),
      ],
      subjects: [
        for (final subject in jsonObjects(json['subjects']))
          CertificateSubjectModel.fromJson(subject),
      ],
    );
  }
}
