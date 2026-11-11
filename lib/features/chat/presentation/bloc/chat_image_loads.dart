import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_attachment_kind.dart';

/// The pictures a page shows (the chat, Homework, an excuse) by attachment
/// id — a photo, or a PDF's first page: where each is saved on the phone,
/// loading, or why it didn't load.
typedef ChatImages = Map<int, BaseState<String>>;

/// Saves an attachment, or a picture of it, on the phone; the result is
/// where. A page's use case, e.g. `downloadChatAttachment.call`.
typedef FetchAttachment =
    Future<Result<String>> Function(
      ChatAttachmentEntity attachment, {
      CancelHandle? cancel,
    });

/// Loads the pictures a page's bloc shows (photos, and PDFs' first pages),
/// several at once: each is saved on the phone by its id, so it comes
/// once. [cancelAll] when the bloc closes.
class ChatImageLoads {
  /// Photos come from [download], PDFs' first pages from [preview].
  ChatImageLoads({
    required FetchAttachment download,
    required FetchAttachment preview,
  }) : _download = download,
       _preview = preview;

  final FetchAttachment _download;
  final FetchAttachment _preview;

  /// The pictures on their way, by attachment id.
  final Map<int, CancelHandle> _loads = {};

  /// Loads [attachment]'s picture (a PDF: its first page), [emit] getting
  /// the pictures at each step. Nothing when [images] has it saved or on
  /// its way, or while the school can't hand it out. [onSignedOut] when
  /// the parent was signed out (the page logs out).
  Future<void> load(
    ChatAttachmentEntity attachment, {
    required ChatImages Function() images,
    required void Function(ChatImages images) emit,
    required void Function(UnauthorizedException exception) onSignedOut,
  }) async {
    final id = attachment.id;
    final shown = images()[id]?.state;
    if (!attachment.isAvailable ||
        shown == StateType.loading ||
        shown == StateType.success) {
      return;
    }
    final cancel = _loads[id] = CancelHandle();
    emit({...images(), id: const BaseState.loading()});
    final result = attachment.isPdf
        ? await _preview(attachment, cancel: cancel)
        : await _download(attachment, cancel: cancel);
    _loads.remove(id);
    result.when(
      success: (path) => emit({...images(), id: BaseState.success(path)}),
      failure: (exception) {
        // The page closed: no one to show it to.
        if (exception is CancelledException) return;
        if (exception is UnauthorizedException) onSignedOut(exception);
        emit({...images(), id: BaseState.error(exception)});
      },
    );
  }

  /// Stops every photo still on its way.
  void cancelAll() {
    for (final load in _loads.values) {
      load.cancel();
    }
    _loads.clear();
  }
}
