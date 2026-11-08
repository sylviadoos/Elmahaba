import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_parent_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/labeled_value_entity.dart';

/// Everything the school has on one of the parent's children. Null for
/// what it doesn't.
class ChildDetailsEntity extends Equatable {
  const ChildDetailsEntity({
    required this.child,
    this.studentCode,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.religion,
    this.nationality,
    this.address,
    this.homePhone,
    this.email,
    this.previousSchool,
    this.father,
    this.mother,
    this.guardianName,
    this.enrolledAt,
  });

  /// Name, grade and class, as in the list of children.
  final ChildEntity child;
  final String? studentCode;
  final DateTime? dateOfBirth;

  /// In years.
  final int? age;
  final LabeledValueEntity? gender;
  final LabeledValueEntity? religion;
  final LabeledValueEntity? nationality;
  final String? address;
  final String? homePhone;
  final String? email;
  final String? previousSchool;
  final ChildParentEntity? father;
  final ChildParentEntity? mother;

  /// Who looks after the child, when it's neither parent.
  final String? guardianName;
  final DateTime? enrolledAt;

  @override
  List<Object?> get props => [
    child,
    studentCode,
    dateOfBirth,
    age,
    gender,
    religion,
    nationality,
    address,
    homePhone,
    email,
    previousSchool,
    father,
    mother,
    guardianName,
    enrolledAt,
  ];
}
