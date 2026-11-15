import 'package:equatable/equatable.dart';

/// Who the fee statement is for.
class FeeStudentEntity extends Equatable {
  const FeeStudentEntity({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameAr,
    required this.nationalId,
    required this.grade,
    required this.academicYear,
  });

  final int id;
  final String name;
  final String nameEn;
  final String nameAr;

  /// In full, e.g. "31806012500923".
  final String nationalId;

  /// e.g. "Second Primary".
  final String grade;

  /// e.g. "2026-2027".
  final String academicYear;

  @override
  List<Object?> get props => [
    id,
    name,
    nameEn,
    nameAr,
    nationalId,
    grade,
    academicYear,
  ];
}
