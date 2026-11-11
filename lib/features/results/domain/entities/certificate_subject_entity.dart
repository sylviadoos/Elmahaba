import 'package:equatable/equatable.dart';

/// A subject on the monthly certificate: what its mark is made of, and the
/// marks of each month it has.
class CertificateSubjectEntity extends Equatable {
  const CertificateSubjectEntity({
    required this.subjectId,
    required this.name,
    this.includedInTotal,
    this.components = const [],
    this.marks = const {},
  });

  final int subjectId;

  /// In English, e.g. "Arabic".
  final String name;

  /// Whether it counts in the months' totals (Religion doesn't); null when
  /// the school doesn't say.
  final bool? includedInTotal;

  /// e.g. "Monthly exam" out of 15, "Homework" out of 5.
  final List<CertificateComponentEntity> components;

  /// By month key ("m0"); a month it has no marks for isn't in it.
  final Map<String, CertificateMarksEntity> marks;

  @override
  List<Object?> get props => [
    subjectId,
    name,
    includedInTotal,
    components,
    marks,
  ];
}

/// One part of a subject's monthly mark, e.g. "Monthly exam" out of 15.
class CertificateComponentEntity extends Equatable {
  const CertificateComponentEntity({required this.name, required this.max});

  final String name;
  final double max;

  @override
  List<Object?> get props => [name, max];
}

/// A subject's marks in one month.
class CertificateMarksEntity extends Equatable {
  const CertificateMarksEntity({
    this.components = const {},
    this.total,
    this.maxTotal,
    this.includedInTotal,
  });

  /// By the component's name, e.g. {"Monthly exam": 14}.
  final Map<String, double> components;
  final double? total;
  final double? maxTotal;

  /// Whether it counts in that month's total; null when not said.
  final bool? includedInTotal;

  @override
  List<Object?> get props => [components, total, maxTotal, includedInTotal];
}
