import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absences_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/repos/excuses_repo.dart';

/// A child's absences and whether an excuse can be sent for each:
/// `await getExcusableAbsences(childId);`
@lazySingleton
class GetExcusableAbsencesUseCase {
  GetExcusableAbsencesUseCase(this._repo);

  final ExcusesRepo _repo;

  Future<Result<ExcusableAbsencesEntity>> call(int childId, {DateTime? date}) =>
      _repo.getAbsences(childId, date: date);
}
