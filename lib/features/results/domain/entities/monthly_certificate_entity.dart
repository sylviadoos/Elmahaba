import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/results/domain/entities/certificate_month_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/certificate_subject_entity.dart';

/// The monthly examination certificate: the student, then each month's
/// totals and each subject's marks in them.
class MonthlyCertificateEntity extends Equatable {
  const MonthlyCertificateEntity({
    required this.studentName,
    required this.studentNameAr,
    required this.grade,
    required this.className,
    required this.academicYear,
    this.months = const [],
    this.subjects = const [],
  });

  final String studentName;

  /// Empty when the school has none.
  final String studentNameAr;

  /// e.g. "First Primary".
  final String grade;

  /// e.g. "A".
  final String className;

  /// e.g. "2026-2027".
  final String academicYear;

  /// Oldest first.
  final List<CertificateMonthEntity> months;
  final List<CertificateSubjectEntity> subjects;

  @override
  List<Object?> get props => [
    studentName,
    studentNameAr,
    grade,
    className,
    academicYear,
    months,
    subjects,
  ];
}
