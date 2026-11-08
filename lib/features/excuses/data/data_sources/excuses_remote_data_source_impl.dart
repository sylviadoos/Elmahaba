import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/core/network/multipart_files.dart';
import 'package:al_mahhaba_school/features/excuses/data/data_sources/excuses_remote_data_source.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/excusable_absences_model.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/excuse_details_model.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/new_excuse_model.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';

@LazySingleton(as: ExcusesRemoteDataSource)
class ExcusesRemoteDataSourceImpl implements ExcusesRemoteDataSource {
  ExcusesRemoteDataSourceImpl(
    @Named(ApiNames.school) this._api,
    @Named(ApiNames.signedFiles) this._signedFiles,
  );

  final ApiService _api;

  /// For the signed links documents are fetched by: without the token.
  final ApiService _signedFiles;

  @override
  Future<ExcusableAbsencesModel> getAbsences(
    int childId, {
    DateTime? date,
  }) async {
    // { "status": "success", "data": { "student_id": 345,
    //   "rules": {…}, "absences": […] } }
    final json =
        await _api.get(
              ApiEndpoints.childExcuseAbsences(childId),
              queryParameters: {
                if (date != null) 'date': DateFormat('yyyy-MM-dd').format(date),
              },
            )
            as Map<String, dynamic>;
    return ExcusableAbsencesModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<ExcuseDetailsModel> submitExcuse(
    int childId,
    NewExcuseModel excuse,
  ) async {
    // 201 { "status": "success", "code": "excuse_submitted",
    //   "data": { …excuse… } }
    final json =
        await _api.upload(
              ApiEndpoints.childExcuses(childId),
              formData: await excuse.toFormData(),
            )
            as Map<String, dynamic>;
    return ExcuseDetailsModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<ExcuseDetailsModel> getExcuse(int childId, int excuseId) async {
    final json =
        await _api.get(ApiEndpoints.childExcuse(childId, excuseId))
            as Map<String, dynamic>;
    return ExcuseDetailsModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<ExcuseDetailsModel> addDocuments(
    int childId,
    int excuseId,
    List<String> documents,
  ) async {
    // { "status": "success", "code": "excuse_documents_added",
    //   "data": { …excuse, back to "submitted", with the new files… } }
    final json =
        await _api.upload(
              ApiEndpoints.childExcuseDocuments(childId, excuseId),
              formData: FormData()
                ..files.addAll(await multipartFiles('documents[]', documents)),
            )
            as Map<String, dynamic>;
    return ExcuseDetailsModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<String> downloadDocument(
    int childId,
    int excuseId,
    ExcuseDocumentEntity document,
  ) async {
    final folder = await getTemporaryDirectory();
    // The server's name, minus anything that would leave the folder.
    final name = document.fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File('${folder.path}/excuse_documents/${document.id}_$name');
    if (!await file.exists()) {
      // { "status": "success", "data": { "file_name": "…", "mime": "…",
      //   "url": "…/signed/310?…", "expires_in_minutes": 10 } }
      final json =
          await _api.get(
                ApiEndpoints.childExcuseDocument(
                  childId,
                  excuseId,
                  document.id,
                ),
              )
              as Map<String, dynamic>;
      final data = json[ApiKeys.data] as Map<String, dynamic>;
      await file.parent.create(recursive: true);
      await _signedFiles.download(data['url'] as String, file.path);
    }
    return file.path;
  }
}
