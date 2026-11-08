import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/results/domain/entities/result_component_entity.dart';

/// A subject's mark, and the parts it's made of.
class ResultSubjectEntity extends Equatable {
  const ResultSubjectEntity({
    required this.name,
    required this.total,
    required this.maxTotal,
    required this.components,
    this.initialAssessment,
    this.finalAssessment,
    this.status,
  });

  /// e.g. "Arabic".
  final String name;
  final double total;
  final double maxTotal;
  final List<ResultComponentEntity> components;

  /// As the school wrote them, e.g. "اجتاز"; null when not given.
  final String? initialAssessment;
  final String? finalAssessment;
  final String? status;

  /// [total] out of [maxTotal], 0–1.
  double get share => maxTotal > 0 ? (total / maxTotal).clamp(0, 1) : 0;

  @override
  List<Object?> get props => [
    name,
    total,
    maxTotal,
    components,
    initialAssessment,
    finalAssessment,
    status,
  ];
}
