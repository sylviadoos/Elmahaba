import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_item_model.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_page_model.dart';
import 'package:al_mahhaba_school/features/chat/data/models/new_chat_message_model.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';

/// Talks to the school system's chat endpoints (signed in). Throws an
/// `AppException` on failure; a `CancelledException` once [cancel]led.
abstract interface class ChatRemoteDataSource {
  /// The newest items, or those [before] a page's `nextBefore`: one
  /// child's ([studentId]) with the general ones, or everything. Fails with
  /// a `ServerException` (`child_not_available`) for a child no longer
  /// linked. [limit] items at most; 30 when not given.
  Future<ChatPageModel> getChat({
    int? studentId,
    String? before,
    int? limit,
    CancelHandle? cancel,
  });

  Future<int> getUnreadCount();

  /// Fails with a 422 `ServerException`: `text_or_attachment_required`,
  /// `file_type_or_size_not_allowed`, `too_many_attachments`,
  /// `file_rejected` or `reply_not_allowed`; with a 409 one (`chat_closed`)
  /// while the school has closed the chat. [onProgress] follows the upload.
  Future<ChatItemModel> sendMessage(
    NewChatMessageModel message, {
    UploadProgressCallback? onProgress,
    CancelHandle? cancel,
  });

  /// Returns what's still unread.
  Future<int> markRead(List<String> keys);

  /// Saves the file in the app's temporary folder (once: a saved one is
  /// reused) and returns its path. The file comes by a signed link, without
  /// the token.
  Future<String> downloadAttachment(
    ChatAttachmentEntity attachment, {
    CancelHandle? cancel,
  });
}
