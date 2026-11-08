import 'package:al_mahhaba_school/features/excuses/data/models/excusable_absences_model.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/excuse_details_model.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/new_excuse_model.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';

/// Talks to the school system's medical excuse endpoints (signed in).
/// Throws an `AppException` on failure.
abstract interface class ExcusesRemoteDataSource {
  Future<ExcusableAbsencesModel> getAbsences(int childId, {DateTime? date});

  Future<ExcuseDetailsModel> submitExcuse(int childId, NewExcuseModel excuse);

  Future<ExcuseDetailsModel> getExcuse(int childId, int excuseId);

  /// The excuse comes back with them.
  Future<ExcuseDetailsModel> addDocuments(
    int childId,
    int excuseId,
    List<String> documents,
  );

  /// Saves [document] in the phone's temporary files (once); its path.
  Future<String> downloadDocument(
    int childId,
    int excuseId,
    ExcuseDocumentEntity document,
  );
}
