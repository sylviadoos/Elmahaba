import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/certificate_subject_entity.dart';

class CertificateSubjectModel extends CertificateSubjectEntity {
  const CertificateSubjectModel({
    required super.subjectId,
    required super.name,
    super.includedInTotal,
    super.components,
    super.marks,
  });

  /// { "subject_id": 24, "name": "Arabic", "in_grade": true,
  ///   "included_in_total": true,
  ///   "components": [ { "name": "Monthly exam", "max": 15 }, … ],
  ///   "marks": { "m0": { "components": { "Monthly exam": 14, … },
  ///   "total": 38, "max_total": 40, "included_in_total": true } } } —
  /// `marks` is {} (or a list) when there are none yet.
  factory CertificateSubjectModel.fromJson(Map<String, dynamic> json) =>
      CertificateSubjectModel(
        subjectId: json['subject_id'] as int? ?? 0,
        name: jsonText(json['name']),
        includedInTotal: json['included_in_total'] as bool?,
        components: [
          for (final component in jsonObjects(json['components']))
            CertificateComponentEntity(
              name: jsonText(component['name']),
              max: jsonDouble(component['max']) ?? 0,
            ),
        ],
        marks: {
          if (json['marks'] case final Map<String, dynamic> marks)
            for (final MapEntry(:key, :value) in marks.entries)
              if (value case final Map<String, dynamic> month)
                key: _marks(month),
        },
      );

  static CertificateMarksEntity _marks(Map<String, dynamic> json) =>
      CertificateMarksEntity(
        components: {
          if (json['components'] case final Map<String, dynamic> components)
            for (final MapEntry(:key, :value) in components.entries)
              // A part not marked yet is left out.
              if (jsonDouble(value) case final double mark) key: mark,
        },
        total: jsonDouble(json['total']),
        maxTotal: jsonDouble(json['max_total']),
        includedInTotal: json['included_in_total'] as bool?,
      );
}
