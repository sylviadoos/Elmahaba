import 'package:equatable/equatable.dart';

/// An activity graded with a word, not a mark, e.g. "Tokkatsu" · "اجتاز".
class ResultActivityEntity extends Equatable {
  const ResultActivityEntity({required this.name, this.status});

  final String name;

  /// As the school wrote it, e.g. "اجتاز"; null when not given.
  final String? status;

  /// Whether [status] is a pass ("اجتاز", "ممتاز", "passed").
  bool get passed => const {
    'اجتاز',
    'ممتاز',
    'passed',
    'pass',
  }.contains(status?.trim().toLowerCase());

  @override
  List<Object?> get props => [name, status];
}
