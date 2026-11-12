import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/results/domain/entities/result_activity_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_kind.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_period_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_subject_entity.dart';

/// A published result (report card), in full: a month's or a term's.
class ResultDetailsEntity extends Equatable {
  const ResultDetailsEntity({
    required this.id,
    this.kind = ResultKind.other,
    required this.title,
    required this.academicYear,
    required this.resultType,
    this.period,
    this.publishedAt,
    this.studentName = '',
    this.finalResult,
    this.finalResultMax,
    this.verdict,
    this.rank,
    this.attendancePercentage,
    required this.subjectsIncluded,
    required this.subjectsNotIncluded,
    required this.highLevel,
    required this.activities,
  });

  final int id;

  /// A month's, a term's…
  final ResultKind kind;

  /// As the school wrote it, e.g. "نتيجة الصف الثالث شهر اكتوبر".
  final String title;

  /// e.g. "2026-2027".
  final String academicYear;

  /// How the grades are shown: "value", or "value and color".
  final String resultType;

  /// The month a monthly result is for; null for any other.
  final ResultPeriodEntity? period;
  final DateTime? publishedAt;

  /// Empty when the school doesn't send it.
  final String studentName;

  /// The counted subjects' marks together, e.g. 245; null when not given.
  final double? finalResult;

  /// What [finalResult] is out of, when the school says (a month's);
  /// otherwise worked out from [subjectsIncluded].
  final double? finalResultMax;

  /// The school's word for the outcome, e.g. "ناجح" (a term's); null when
  /// not given.
  final String? verdict;

  /// In the class, 1 the first; null when not given.
  final int? rank;

  /// 0–100; null when not given.
  final double? attendancePercentage;

  /// Counted in [finalResult].
  final List<ResultSubjectEntity> subjectsIncluded;

  /// Not counted in [finalResult] (e.g. Religion).
  final List<ResultSubjectEntity> subjectsNotIncluded;

  /// An extra level, not counted in [finalResult].
  final List<ResultSubjectEntity> highLevel;
  final List<ResultActivityEntity> activities;

  bool get isMonthly => kind == ResultKind.monthly;

  /// Whether the grades are shown in colors, by how good they are.
  bool get usesColors => resultType.contains('color');

  /// What [finalResult] is out of.
  double get finalMax =>
      finalResultMax ??
      subjectsIncluded.fold(0, (sum, subject) => sum + subject.maxTotal);

  @override
  List<Object?> get props => [
    id,
    kind,
    title,
    academicYear,
    resultType,
    period,
    publishedAt,
    studentName,
    finalResult,
    finalResultMax,
    verdict,
    rank,
    attendancePercentage,
    subjectsIncluded,
    subjectsNotIncluded,
    highLevel,
    activities,
  ];
}
