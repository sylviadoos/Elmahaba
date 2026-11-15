import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/repos/excuses_repo.dart';

/// Saves an excuse's document on the phone, to open it:
/// `final path = await downloadExcuseDocument(childId, excuseId, document);`
@lazySingleton
class DownloadExcuseDocumentUseCase {
  DownloadExcuseDocumentUseCase(this._repo);

  final ExcusesRepo _repo;

  Future<Result<String>> call(
    int childId,
    int excuseId,
    ExcuseDocumentEntity document,
  ) => _repo.downloadDocument(childId, excuseId, document);
}
