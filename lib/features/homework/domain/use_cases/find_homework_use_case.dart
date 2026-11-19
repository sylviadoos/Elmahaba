import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/repos/homework_repo.dart';

/// One of a child's homework, by its id — for the chat, which names the
/// homework but doesn't carry it:
/// `final result = await findHomework(child.studentId, homeworkId);`
///
/// The school has no call for one homework, so it's looked for in the
/// child's list, a page at a time from the newest — the one tapped in the
/// chat is usually on the first. Null when it isn't there (deleted).
/// [cancel] stops it when it's no longer needed.
@lazySingleton
class FindHomeworkUseCase {
  FindHomeworkUseCase(this._repo);

  final HomeworkRepo _repo;

  Future<Result<HomeworkEntity?>> call(
    int childId,
    int homeworkId, {
    CancelHandle? cancel,
  }) async {
    for (var page = 1; ; page++) {
      final result = await _repo.getHomework(
        childId,
        page: page,
        cancel: cancel,
      );
      switch (result) {
        case Failure(:final exception):
          return Failure(exception: exception);
        case Success(:final data):
          for (final homework in data.items) {
            if (homework.id == homeworkId) return Success(data: homework);
          }
          if (!data.hasMore) return const Success(data: null);
      }
    }
  }
}
