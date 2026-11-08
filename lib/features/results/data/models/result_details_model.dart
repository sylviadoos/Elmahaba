import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_activity_model.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_subject_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

/// The `data` of `GET v1/parent/children/{child_id}/results/{result_id}`.
///
/// The marks are in `result`; any list in it may be missing (no high level,
/// no activities…) and reads as empty.
class ResultDetailsModel extends ResultDetailsEntity {
  const ResultDetailsModel({
    required super.id,
    required super.title,
    required super.academicYear,
    required super.resultType,
    super.publishedAt,
    required super.studentName,
    super.finalResult,
    super.attendancePercentage,
    required super.subjectsIncluded,
    required super.subjectsNotIncluded,
    required super.highLevel,
    required super.activities,
  });

  factory ResultDetailsModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? const {};
    List<ResultSubjectModel> subjects(String key) => [
      for (final subject in jsonObjects(result[key]))
        ResultSubjectModel.fromJson(subject),
    ];

    return ResultDetailsModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      academicYear: json['academic_year'] as String? ?? '',
      resultType: json['result_type'] as String? ?? '',
      // "2026-06-03T11:55:34+00:00", in UTC.
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
      studentName: jsonText(result['studentName']),
      // "297.4", or the rounded "297" when that's all there is.
      finalResult:
          jsonDouble(result['finalResult']) ??
          jsonDouble(result['finalResult2']),
      attendancePercentage: jsonDouble(result['attendancePercentage']),
      subjectsIncluded: subjects('subjectsIncluded'),
      subjectsNotIncluded: subjects('subjectsNotIncluded'),
      highLevel: subjects('highLevel'),
      activities: [
        for (final activity in jsonObjects(result['activities']))
          ResultActivityModel.fromJson(activity),
      ],
    );
  }
}
