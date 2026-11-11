import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/repos/excuses_repo.dart';

/// An excuse's PDF document's first page as a picture saved on the phone,
/// to show in place of the file:
/// `final path = await previewExcuseDocument(childId, excuseId, document);`
@lazySingleton
class PreviewExcuseDocumentUseCase {
  PreviewExcuseDocumentUseCase(this._repo);

  final ExcusesRepo _repo;

  Future<Result<String>> call(
    int childId,
    int excuseId,
    ExcuseDocumentEntity document,
  ) => _repo.previewDocument(childId, excuseId, document);
}
