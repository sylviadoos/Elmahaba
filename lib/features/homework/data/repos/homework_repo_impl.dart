import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/homework/data/data_sources/homework_remote_data_source.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_page_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/repos/homework_repo.dart';

@LazySingleton(as: HomeworkRepo)
class HomeworkRepoImpl implements HomeworkRepo {
  HomeworkRepoImpl(this._remoteDataSource);

  final HomeworkRemoteDataSource _remoteDataSource;

  @override
  Future<Result<HomeworkPageEntity>> getHomework(
    int childId, {
    HomeworkFilter filter = HomeworkFilter.all,
    int? subjectId,
    int page = 1,
    CancelHandle? cancel,
  }) => Result.guard(
    () => _remoteDataSource.getHomework(
      childId,
      filter: filter,
      subjectId: subjectId,
      page: page,
      cancel: cancel,
    ),
  );
}
