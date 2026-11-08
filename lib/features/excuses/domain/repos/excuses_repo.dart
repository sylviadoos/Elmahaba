import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absences_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/new_excuse_entity.dart';

/// A child's medical excuses for absences ([childId] is their
/// `studentId`). Never throws — errors come back as a `Failure`.
abstract interface class ExcusesRepo {
  /// The absences an excuse can be (or was) sent for; only the one on
  /// [date] when given.
  Future<Result<ExcusableAbsencesEntity>> getAbsences(
    int childId, {
    DateTime? date,
  });

  /// Sends [excuse]; it comes back as the school has it.
  Future<Result<ExcuseDetailsEntity>> submitExcuse(
    int childId,
    NewExcuseEntity excuse,
  );

  Future<Result<ExcuseDetailsEntity>> getExcuse(int childId, int excuseId);

  /// Adds the files at [documents] (paths) to one the school asked more
  /// for; it comes back with them, being reviewed again.
  Future<Result<ExcuseDetailsEntity>> addDocuments(
    int childId,
    int excuseId,
    List<String> documents,
  );

  /// Saves [document] on the phone; its path.
  Future<Result<String>> downloadDocument(
    int childId,
    int excuseId,
    ExcuseDocumentEntity document,
  );
}
