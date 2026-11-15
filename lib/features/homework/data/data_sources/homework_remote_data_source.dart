import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/features/homework/data/models/homework_page_model.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';

/// Talks to the school system's homework endpoint (signed in). Throws an
/// `AppException` on failure; a `CancelledException` once [cancel]led.
abstract interface class HomeworkRemoteDataSource {
  /// One [page] of the child's homework that [filter] picks, in the subject
  /// [subjectId] (any for null). A read-only child fails with a 403
  /// `ServerException` (`read_only_child`).
  Future<HomeworkPageModel> getHomework(
    int childId, {
    HomeworkFilter filter = HomeworkFilter.all,
    int? subjectId,
    int page = 1,
    CancelHandle? cancel,
  });
}
