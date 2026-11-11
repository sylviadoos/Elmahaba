import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/features/announcements/data/models/announcements_page_model.dart';

/// Talks to the school system's announcements endpoint (signed in). Throws
/// an `AppException` on failure; a `CancelledException` once [cancel]led.
abstract interface class AnnouncementsRemoteDataSource {
  /// One [page] of the announcements to the child's parents. A read-only
  /// child fails with a 403 `ServerException` (`read_only_child`).
  Future<AnnouncementsPageModel> getAnnouncements(
    int childId, {
    int page = 1,
    CancelHandle? cancel,
  });
}
