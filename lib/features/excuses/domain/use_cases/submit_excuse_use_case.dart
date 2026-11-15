import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/new_excuse_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/repos/excuses_repo.dart';

/// Sends a medical excuse for an absence:
/// `await submitExcuse(childId, excuse);`
@lazySingleton
class SubmitExcuseUseCase {
  SubmitExcuseUseCase(this._repo);

  final ExcusesRepo _repo;

  Future<Result<ExcuseDetailsEntity>> call(
    int childId,
    NewExcuseEntity excuse,
  ) => _repo.submitExcuse(childId, excuse);
}
