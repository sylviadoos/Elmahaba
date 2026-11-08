import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/repos/home_repo.dart';

/// The newest few results a child got:
/// `final result = await getLatestResults(child.studentId);`
@lazySingleton
class GetLatestResultsUseCase {
  GetLatestResultsUseCase(this._repo);

  final HomeRepo _repo;

  Future<Result<LatestItemsEntity<LatestResultEntity>>> call(int childId) =>
      _repo.getLatestResults(childId);
}
