import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/repos/home_repo.dart';

/// The newest few announcements for a child's parents:
/// `final result = await getLatestAnnouncements(child.studentId);`
@lazySingleton
class GetLatestAnnouncementsUseCase {
  GetLatestAnnouncementsUseCase(this._repo);

  final HomeRepo _repo;

  Future<Result<LatestItemsEntity<AnnouncementEntity>>> call(int childId) =>
      _repo.getLatestAnnouncements(childId);
}
