import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/new_chat_message_entity.dart';

/// Never throws — errors come back as a `Failure` (a `CancelledException`
/// once [CancelHandle.cancel]led).
abstract interface class ChatRepo {
  /// The newest items, or those [before] a page's `nextBefore`: one
  /// child's ([studentId]) with the general ones, or everything. The newest
  /// are kept, for [cachedChat].
  Future<Result<ChatPageEntity>> getChat({
    int? studentId,
    String? before,
    CancelHandle? cancel,
  });

  /// The newest page of [studentId]'s chat as [getChat] last brought it,
  /// to show while it loads again; null when it hasn't.
  ChatPageEntity? cachedChat(int? studentId);

  /// How many items the parent hasn't read.
  Future<Result<int>> getUnreadCount();

  /// Sends [message]; the result is it as the chat shows it. [onProgress]
  /// follows the upload.
  Future<Result<ChatItemEntity>> sendMessage(
    NewChatMessageEntity message, {
    UploadProgressCallback? onProgress,
    CancelHandle? cancel,
  });

  /// Tells the school the parent saw the items with these keys; the result
  /// is what's still unread.
  Future<Result<int>> markRead(List<String> keys);

  /// Saves [attachment] on the phone; the result is where.
  Future<Result<String>> downloadAttachment(
    ChatAttachmentEntity attachment, {
    CancelHandle? cancel,
  });
}
