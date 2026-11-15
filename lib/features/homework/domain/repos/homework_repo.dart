import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_page_entity.dart';

/// Never throws — errors come back as a `Failure` (a `CancelledException`
/// once [CancelHandle.cancel]led).
abstract interface class HomeworkRepo {
  /// One [page] (from 1) of the child's homework, newest given first: those
  /// [filter] picks, in the subject [subjectId] (any for null). A read-only
  /// child fails with a 403 `read_only_child`.
  Future<Result<HomeworkPageEntity>> getHomework(
    int childId, {
    HomeworkFilter filter = HomeworkFilter.all,
    int? subjectId,
    int page = 1,
    CancelHandle? cancel,
  });
}
