import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/announcements/data/data_sources/announcements_remote_data_source.dart';
import 'package:al_mahhaba_school/features/announcements/domain/entities/announcements_page_entity.dart';
import 'package:al_mahhaba_school/features/announcements/domain/repos/announcements_repo.dart';

@LazySingleton(as: AnnouncementsRepo)
class AnnouncementsRepoImpl implements AnnouncementsRepo {
  AnnouncementsRepoImpl(this._remoteDataSource);

  final AnnouncementsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AnnouncementsPageEntity>> getAnnouncements(
    int childId, {
    int page = 1,
    CancelHandle? cancel,
  }) => Result.guard(
    () =>
        _remoteDataSource.getAnnouncements(childId, page: page, cancel: cancel),
  );
}
