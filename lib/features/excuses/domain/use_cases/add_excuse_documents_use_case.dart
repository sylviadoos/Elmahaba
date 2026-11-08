import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/repos/excuses_repo.dart';

/// Adds documents the school asked for; the excuse comes back with them:
/// `final updated = await addExcuseDocuments(childId, excuseId, paths);`
@lazySingleton
class AddExcuseDocumentsUseCase {
  AddExcuseDocumentsUseCase(this._repo);

  final ExcusesRepo _repo;

  Future<Result<ExcuseDetailsEntity>> call(
    int childId,
    int excuseId,
    List<String> documents,
  ) => _repo.addDocuments(childId, excuseId, documents);
}
