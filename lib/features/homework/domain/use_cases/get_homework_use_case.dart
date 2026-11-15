import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_page_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/repos/homework_repo.dart';

/// A child's homework, a page at a time:
/// `final result = await getHomework(child.studentId);`, then
/// `getHomework(child.studentId, page: loaded.page + 1)` for more.
/// [cancel] stops it when it's no longer needed.
@lazySingleton
class GetHomeworkUseCase {
  GetHomeworkUseCase(this._repo);

  final HomeworkRepo _repo;

  Future<Result<HomeworkPageEntity>> call(
    int childId, {
    HomeworkFilter filter = HomeworkFilter.all,
    int? subjectId,
    int page = 1,
    CancelHandle? cancel,
  }) => _repo.getHomework(
    childId,
    filter: filter,
    subjectId: subjectId,
    page: page,
    cancel: cancel,
  );
}
