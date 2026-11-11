import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/pdf/pdf_previewer.dart';
import 'package:al_mahhaba_school/features/excuses/data/data_sources/excuses_remote_data_source.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/new_excuse_model.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absences_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/new_excuse_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/repos/excuses_repo.dart';

@LazySingleton(as: ExcusesRepo)
class ExcusesRepoImpl implements ExcusesRepo {
  ExcusesRepoImpl(this._remoteDataSource, this._pdfPreviewer);

  final ExcusesRemoteDataSource _remoteDataSource;
  final PdfPreviewer _pdfPreviewer;

  @override
  Future<Result<ExcusableAbsencesEntity>> getAbsences(
    int childId, {
    DateTime? date,
  }) => Result.guard(() => _remoteDataSource.getAbsences(childId, date: date));

  @override
  Future<Result<ExcuseDetailsEntity>> submitExcuse(
    int childId,
    NewExcuseEntity excuse,
  ) => Result.guard(
    () => _remoteDataSource.submitExcuse(
      childId,
      NewExcuseModel.fromEntity(excuse),
    ),
  );

  @override
  Future<Result<ExcuseDetailsEntity>> getExcuse(int childId, int excuseId) =>
      Result.guard(() => _remoteDataSource.getExcuse(childId, excuseId));

  @override
  Future<Result<ExcuseDetailsEntity>> addDocuments(
    int childId,
    int excuseId,
    List<String> documents,
  ) => Result.guard(
    () => _remoteDataSource.addDocuments(childId, excuseId, documents),
  );

  @override
  Future<Result<String>> downloadDocument(
    int childId,
    int excuseId,
    ExcuseDocumentEntity document,
  ) => Result.guard(
    () => _remoteDataSource.downloadDocument(childId, excuseId, document),
  );

  @override
  Future<Result<String>> previewDocument(
    int childId,
    int excuseId,
    ExcuseDocumentEntity document,
  ) => Result.guard(() async {
    final path = await _remoteDataSource.downloadDocument(
      childId,
      excuseId,
      document,
    );
    return _pdfPreviewer.firstPage(path);
  });
}
