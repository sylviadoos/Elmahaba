import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/repos/home_repo.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';

@LazySingleton(as: HomeRepo)
class HomeRepoImpl implements HomeRepo {
  HomeRepoImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ChildDashboardEntity>> getChildDashboard(int childId) =>
      Result.guard(() => _remoteDataSource.getChildDashboard(childId));

  @override
  Future<Result<LatestItemsEntity<AnnouncementEntity>>> getLatestAnnouncements(
    int childId,
  ) => Result.guard(() => _remoteDataSource.getLatestAnnouncements(childId));

  @override
  Future<Result<LatestItemsEntity<HomeworkEntity>>> getLatestHomework(
    int childId,
  ) => Result.guard(() => _remoteDataSource.getLatestHomework(childId));

  @override
  Future<Result<LatestItemsEntity<LatestResultEntity>>> getLatestResults(
    int childId,
  ) => Result.guard(() => _remoteDataSource.getLatestResults(childId));
}
