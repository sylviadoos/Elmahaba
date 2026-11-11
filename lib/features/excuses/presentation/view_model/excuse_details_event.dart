import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';

sealed class ExcuseDetailsEvent {
  const ExcuseDetailsEvent();
}

/// Opens the excuse [excuseId] of the child [childId] (`studentId`):
/// [shown] (the excuse as just sent) at once, while it loads.
final class ShowExcuseEvent extends ExcuseDetailsEvent {
  const ShowExcuseEvent({
    required this.childId,
    required this.excuseId,
    this.shown,
  });

  final int childId;
  final int excuseId;
  final ExcuseDetailsEntity? shown;
}

/// Loads the excuse opened again ("Try again", pulling down). With
/// [refresh], what's shown stays until it arrives (or if it can't).
final class LoadExcuseEvent extends ExcuseDetailsEvent {
  const LoadExcuseEvent({this.refresh = false});

  final bool refresh;
}

/// Adds the files at [documents] (paths) the school asked for; the excuse
/// comes back with them.
final class AddExcuseDocumentsEvent extends ExcuseDetailsEvent {
  const AddExcuseDocumentsEvent(this.documents);

  final List<String> documents;
}

/// Saves [document] on the phone, for the page to open it.
final class DownloadExcuseDocumentEvent extends ExcuseDetailsEvent {
  const DownloadExcuseDocumentEvent(this.document);

  final ExcuseDocumentEntity document;
}

/// A document came on screen, or "Try again" on one that didn't load: its
/// picture (the photo, a PDF's first page) is saved on the phone to show.
/// Nothing when it's saved or on its way already.
final class LoadExcuseImageEvent extends ExcuseDetailsEvent {
  const LoadExcuseImageEvent(this.document);

  final ExcuseDocumentEntity document;
}
