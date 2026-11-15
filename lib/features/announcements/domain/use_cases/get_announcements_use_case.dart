import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/announcements/domain/entities/announcements_page_entity.dart';
import 'package:al_mahhaba_school/features/announcements/domain/repos/announcements_repo.dart';

/// The school's announcements to a child's parents, a page at a time:
/// `final result = await getAnnouncements(child.studentId);`, then
/// `getAnnouncements(child.studentId, page: loaded.page + 1)` for more.
/// [cancel] stops it when it's no longer needed.
@lazySingleton
class GetAnnouncementsUseCase {
  GetAnnouncementsUseCase(this._repo);

  final AnnouncementsRepo _repo;

  Future<Result<AnnouncementsPageEntity>> call(
    int childId, {
    int page = 1,
    CancelHandle? cancel,
  }) => _repo.getAnnouncements(childId, page: page, cancel: cancel);
}
