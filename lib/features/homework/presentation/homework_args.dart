import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';

/// What `AppRoutes.homeworkDetails` may be opened with: the [homework]
/// itself when the parent holds it (Home), so nothing is loaded — and
/// whose it is, so it's found and marked for the right child.
class HomeworkArgs extends Equatable {
  const HomeworkArgs({this.homework, this.studentId});

  /// Null from the chat or a notification: it's looked for by its id.
  final HomeworkEntity? homework;

  /// The child it's about; null for the one every page shows.
  final int? studentId;

  @override
  List<Object?> get props => [homework, studentId];
}
