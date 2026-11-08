import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/repos/home_repo.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';

/// The newest few homework a child was given:
/// `final result = await getLatestHomework(child.studentId);`
@lazySingleton
class GetLatestHomeworkUseCase {
  GetLatestHomeworkUseCase(this._repo);

  final HomeRepo _repo;

  Future<Result<LatestItemsEntity<HomeworkEntity>>> call(int childId) =>
      _repo.getLatestHomework(childId);
}
