import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/add_excuse_documents_use_case.dart';
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/download_excuse_document_use_case.dart';
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/get_excuse_details_use_case.dart';
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/preview_excuse_document_use_case.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/extensions/excuse_document_attachment.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excuse_details_event.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excuse_details_state.dart';

/// One medical excuse's page: where it stands, adding documents the school
/// asked for, and its files (photos and PDFs' first pages shown, as in the
/// chat). The page opens a downloaded file itself, hence `void`.
@injectable
class ExcuseDetailsViewModel
    extends BaseCubit<ExcuseDetailsState, ExcuseDetailsEvent, void> {
  ExcuseDetailsViewModel(
    this._getDetails,
    this._addDocuments,
    this._downloadDocument,
    this._previewDocument,
  ) : super(const ExcuseDetailsState());

  final GetExcuseDetailsUseCase _getDetails;
  final AddExcuseDocumentsUseCase _addDocuments;
  final DownloadExcuseDocumentUseCase _downloadDocument;
  final PreviewExcuseDocumentUseCase _previewDocument;

  /// The child's `studentId` and the excuse, once opened.
  int? _childId;
  int? _excuseId;

  /// The documents' pictures, as the chat's files show (asked for once the
  /// excuse is open).
  late final ChatImageLoads _images = ChatImageLoads(
    download: (attachment, {cancel}) =>
        _downloadDocument(_childId!, _excuseId!, attachment.asExcuseDocument),
    preview: (attachment, {cancel}) =>
        _previewDocument(_childId!, _excuseId!, attachment.asExcuseDocument),
  );

  @override
  Future<void> close() {
    _images.cancelAll();
    return super.close();
  }

  @override
  Future<void> doAction(ExcuseDetailsEvent event) async {
    switch (event) {
      case ShowExcuseEvent(:final childId, :final excuseId, :final shown):
        _childId = childId;
        _excuseId = excuseId;
        if (shown != null) {
          emit(state.copyWith(details: BaseState.success(shown)));
        }
        await _load(refresh: shown != null);
      case LoadExcuseEvent(:final refresh):
        await _load(refresh: refresh);
      case AddExcuseDocumentsEvent(:final documents):
        await _add(documents);
      case DownloadExcuseDocumentEvent(:final document):
        await _download(document);
      case LoadExcuseImageEvent(:final document):
        await _loadImage(document);
    }
  }

  /// Saves [document]'s picture on the phone (once: it's kept there by its
  /// id), to show in place of it.
  Future<void> _loadImage(ExcuseDocumentEntity document) async {
    if (_childId == null || _excuseId == null) return;
    await _images.load(
      document.asAttachment,
      images: () => state.images,
      emit: (images) {
        if (!isClosed) emit(state.copyWith(images: images));
      },
      // The page logs out on it.
      onSignedOut: (exception) {
        if (!isClosed) {
          emit(state.copyWith(details: BaseState.error(exception)));
        }
      },
    );
  }

  Future<void> _load({required bool refresh}) async {
    final childId = _childId;
    final excuseId = _excuseId;
    if (childId == null || excuseId == null) return;
    if (state.details.state == StateType.loading) return;
    final shown = refresh ? state.details.data : null;
    if (shown == null) {
      emit(state.copyWith(details: const BaseState.loading()));
    }
    final result = await _getDetails(childId, excuseId);
    if (isClosed) return;
    result.when(
      success: (details) =>
          emit(state.copyWith(details: BaseState.success(details))),
      failure: (exception) {
        // Refreshing: keep showing it.
        if (shown != null) return;
        emit(state.copyWith(details: BaseState.error(exception)));
      },
    );
  }

  Future<void> _add(List<String> documents) async {
    final childId = _childId;
    final excuseId = _excuseId;
    if (childId == null || excuseId == null) return;
    if (state.adding.state == StateType.loading) return;
    emit(state.copyWith(adding: const BaseState.loading()));
    final result = await _addDocuments(childId, excuseId, documents);
    if (isClosed) return;
    result.when(
      // Back in review, with the new files.
      success: (updated) => emit(
        state.copyWith(
          details: BaseState.success(updated),
          adding: const BaseState.success(null),
        ),
      ),
      failure: (exception) =>
          emit(state.copyWith(adding: BaseState.error(exception))),
    );
  }

  Future<void> _download(ExcuseDocumentEntity document) async {
    final childId = _childId;
    final excuseId = _excuseId;
    if (childId == null || excuseId == null) return;
    if (state.downloadingId != null) return;
    emit(
      state.copyWith(
        download: const BaseState.loading(),
        downloadingId: () => document.id,
      ),
    );
    final result = await _downloadDocument(childId, excuseId, document);
    if (isClosed) return;
    emit(
      state.copyWith(
        download: result.when(
          success: BaseState.success,
          failure: BaseState.error,
        ),
        downloadingId: () => null,
      ),
    );
  }
}
