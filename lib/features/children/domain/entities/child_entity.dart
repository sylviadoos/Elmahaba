import 'package:equatable/equatable.dart';

/// A student linked to the parent's account.
class ChildEntity extends Equatable {
  const ChildEntity({
    required this.studentId,
    required this.name,
    required this.nameAr,
    required this.nationalId,
    required this.relationship,
    required this.access,
    this.readOnlyUntil,
    this.photoUrl,
    required this.grade,
    required this.className,
    required this.academicYear,
  });

  final int studentId;
  final String name;
  final String nameAr;

  /// Only the last digits, e.g. "••••2341".
  final String nationalId;

  /// The parent's relationship to the child, e.g. "father".
  final String relationship;

  /// What the parent can do for this child, e.g. "active".
  final String access;
  final DateTime? readOnlyUntil;
  final String? photoUrl;

  /// e.g. "Fourth Primary".
  final String grade;

  /// e.g. "4B".
  final String className;

  /// e.g. "2026-2027".
  final String academicYear;

  @override
  List<Object?> get props => [
    studentId,
    name,
    nameAr,
    nationalId,
    relationship,
    access,
    readOnlyUntil,
    photoUrl,
    grade,
    className,
    academicYear,
  ];
}
