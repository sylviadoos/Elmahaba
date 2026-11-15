import 'package:equatable/equatable.dart';

/// A subject the child has homework in, to filter by.
class HomeworkSubjectEntity extends Equatable {
  const HomeworkSubjectEntity({required this.id, required this.name});

  final int id;

  /// As the school names it, e.g. "Math".
  final String name;

  @override
  List<Object?> get props => [id, name];
}
