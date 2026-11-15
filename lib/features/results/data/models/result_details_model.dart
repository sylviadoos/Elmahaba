import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_activity_model.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_period_model.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_subject_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_kind.dart';

/// One result in the `data` of
/// `GET v1/parent/children/{child_id}/results-v2`.
///
/// The marks are in `data`; any list in it may be missing (a month has no
/// high level or activities) and reads as empty.
class ResultDetailsModel extends ResultDetailsEntity {
  const ResultDetailsModel({
    required super.id,
    super.kind,
    required super.title,
    required super.academicYear,
    required super.resultType,
    super.period,
    super.publishedAt,
    super.finalResult,
    super.finalResultMax,
    super.verdict,
    super.rank,
    super.attendancePercentage,
    required super.subjectsIncluded,
    required super.subjectsNotIncluded,
    required super.highLevel,
    required super.activities,
  });

  /// { "result_id": 820, "result_type": "monthly", "title": "…",
  ///   "academic_year": "2026-2027", "period": { … } | null,
  ///   "display": "value and color", "published_at": "…",
  ///   "data": { "attendance_percentage": 96, "subjects": [ … ],
  ///     "grand_total": 245, "max_grand_total": 280, "rank": 3,
  ///     "high_level": [ … ], "activities": [ … ],
  ///     "final_result": "ناجح", "final_result_2": null } }
  factory ResultDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final counted = <ResultSubjectModel>[];
    final notCounted = <ResultSubjectModel>[];
    for (final subject in jsonObjects(data['subjects'])) {
      // Counted unless the school says not.
      (subject['included_in_total'] as bool? ?? true)
          ? counted.add(ResultSubjectModel.fromJson(subject))
          : notCounted.add(ResultSubjectModel.fromJson(subject));
    }
    // A term's final result is a word ("ناجح") or a mark ("297.4").
    final finalResults = [data['final_result'], data['final_result_2']];
    final verdict = finalResults
        .where((value) => jsonDouble(value) == null)
        .map(jsonText)
        .where((text) => text.isNotEmpty)
        .firstOrNull;
    final period = json['period'];

    return ResultDetailsModel(
      id: json['result_id'] as int,
      kind: ResultKind.of(json['result_type'] as String?),
      title: jsonText(json['title']),
      academicYear: jsonText(json['academic_year']),
      resultType: jsonText(json['display']),
      period: period is Map<String, dynamic>
          ? ResultPeriodModel.fromJson(period)
          : null,
      // "2026-11-11T12:00:00+00:00", in UTC.
      publishedAt: DateTime.tryParse(jsonText(json['published_at'])),
      finalResult:
          jsonDouble(data['grand_total']) ??
          finalResults.map(jsonDouble).nonNulls.firstOrNull ??
          // Not given: the counted subjects' marks together.
          (counted.isEmpty
              ? null
              : counted.fold<double>(0, (sum, s) => sum + s.total)),
      finalResultMax: jsonDouble(data['max_grand_total']),
      verdict: verdict,
      rank: jsonDouble(data['rank'])?.toInt(),
      attendancePercentage: jsonDouble(data['attendance_percentage']),
      subjectsIncluded: counted,
      subjectsNotIncluded: notCounted,
      highLevel: [
        for (final subject in jsonObjects(data['high_level']))
          ResultSubjectModel.fromJson(subject),
      ],
      activities: [
        for (final activity in jsonObjects(data['activities']))
          ResultActivityModel.fromJson(activity),
      ],
    );
  }
}
