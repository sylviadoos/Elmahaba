import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/results/domain/entities/result_activity_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_subject_entity.dart';

/// A published result (report card), in full.
class ResultDetailsEntity extends Equatable {
  const ResultDetailsEntity({
    required this.id,
    required this.title,
    required this.academicYear,
    required this.resultType,
    this.publishedAt,
    required this.studentName,
    this.finalResult,
    this.finalResultMax,
    this.rank,
    this.attendancePercentage,
    required this.subjectsIncluded,
    required this.subjectsNotIncluded,
    required this.highLevel,
    required this.activities,
  });

  final int id;

  /// As the school wrote it, e.g. "نتيجة الصف الاول الابتدائي".
  final String title;

  /// e.g. "2025-2026".
  final String academicYear;

  /// How the grades are shown: "value", or "value and color".
  final String resultType;
  final DateTime? publishedAt;
  final String studentName;

  /// The sum of [subjectsIncluded], e.g. 297.4; null when not given.
  final double? finalResult;

  /// What [finalResult] is out of, when the school says (a month's
  /// certificate); otherwise worked out from [subjectsIncluded].
  final double? finalResultMax;

  /// In the class, 1 the first; null when not given.
  final int? rank;

  /// 0–100; null when not given.
  final double? attendancePercentage;

  /// Counted in [finalResult].
  final List<ResultSubjectEntity> subjectsIncluded;

  /// Not counted in [finalResult] (e.g. Religious).
  final List<ResultSubjectEntity> subjectsNotIncluded;

  /// An extra level, not counted in [finalResult].
  final List<ResultSubjectEntity> highLevel;
  final List<ResultActivityEntity> activities;

  /// Whether the grades are shown in colors, by how good they are.
  bool get usesColors => resultType.contains('color');

  /// What [finalResult] is out of.
  double get finalMax =>
      finalResultMax ??
      subjectsIncluded.fold(0, (sum, subject) => sum + subject.maxTotal);

  @override
  List<Object?> get props => [
    id,
    title,
    academicYear,
    resultType,
    publishedAt,
    studentName,
    finalResult,
    finalResultMax,
    rank,
    attendancePercentage,
    subjectsIncluded,
    subjectsNotIncluded,
    highLevel,
    activities,
  ];
}
