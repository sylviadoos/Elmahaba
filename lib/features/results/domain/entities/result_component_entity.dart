import 'package:equatable/equatable.dart';

/// One part of a subject's mark, e.g. "Oral Tasks" 10 / 10.
class ResultComponentEntity extends Equatable {
  const ResultComponentEntity({
    required this.name,
    required this.mark,
    required this.max,
  });

  final String name;
  final double mark;
  final double max;

  /// [mark] out of [max], 0–1.
  double get share => max > 0 ? (mark / max).clamp(0, 1) : 0;

  @override
  List<Object?> get props => [name, mark, max];
}
