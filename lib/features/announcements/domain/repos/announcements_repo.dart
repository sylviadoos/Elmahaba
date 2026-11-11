import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/announcements/domain/entities/announcements_page_entity.dart';

/// Never throws — errors come back as a `Failure` (a `CancelledException`
/// once [CancelHandle.cancel]led).
abstract interface class AnnouncementsRepo {
  /// One [page] (from 1) of the announcements to the child's parents,
  /// newest first. A read-only child fails with a 403 `read_only_child`.
  Future<Result<AnnouncementsPageEntity>> getAnnouncements(
    int childId, {
    int page = 1,
    CancelHandle? cancel,
  });
}
