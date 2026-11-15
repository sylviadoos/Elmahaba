import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/repos/excuses_repo.dart';

/// A medical excuse in full: `await getExcuseDetails(childId, excuseId);`
@lazySingleton
class GetExcuseDetailsUseCase {
  GetExcuseDetailsUseCase(this._repo);

  final ExcusesRepo _repo;

  Future<Result<ExcuseDetailsEntity>> call(int childId, int excuseId) =>
      _repo.getExcuse(childId, excuseId);
}
