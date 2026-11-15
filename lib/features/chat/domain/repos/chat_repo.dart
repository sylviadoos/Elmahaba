import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_read_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/new_chat_message_entity.dart';

/// Never throws — errors come back as a `Failure` (a `CancelledException`
/// once [CancelHandle.cancel]led).
abstract interface class ChatRepo {
  /// The newest items, or those [before] a page's `nextBefore`: one
  /// child's ([studentId]) with the general ones, or everything; [limit]
  /// at most (a full page when not given). A full page of the newest is
  /// kept, for [cachedChat].
  Future<Result<ChatPageEntity>> getChat({
    int? studentId,
    String? before,
    int? limit,
    CancelHandle? cancel,
  });

  /// The newest page of [studentId]'s chat as [getChat] last brought it,
  /// to show while it loads again; null when it hasn't.
  ChatPageEntity? cachedChat(int? studentId);

  /// How many items of [studentId]'s chat (the general ones included) the
  /// parent hasn't read.
  Future<Result<int>> getUnreadCount({required int studentId});

  /// Sends [message]; the result is it as the chat shows it. [onProgress]
  /// follows the upload.
  Future<Result<ChatItemEntity>> sendMessage(
    NewChatMessageEntity message, {
    UploadProgressCallback? onProgress,
    CancelHandle? cancel,
  });

  /// Tells the school the parent saw the items with these keys; the result
  /// is what's still unread. [studentId] is whose page they were on, when
  /// it's one child's: an item about two of the parent's children is read
  /// for that one only.
  Future<Result<int>> markRead(List<String> keys, {int? studentId});

  /// Each [markRead] the school answered, from any page, even one closed
  /// meanwhile (the chat marks what was seen just before leaving): for
  /// which child, and what's still unread.
  Stream<ChatReadEntity> get onMarkedRead;

  /// Saves [attachment] on the phone; the result is where. [studentId] is
  /// the child whose page it's on (none for the chat's "All").
  Future<Result<String>> downloadAttachment(
    ChatAttachmentEntity attachment, {
    int? studentId,
    CancelHandle? cancel,
  });

  /// Saves [attachment] (a PDF) on the phone and its first page as a
  /// picture beside it, to show in place of it; the result is where the
  /// picture is. [studentId] as for [downloadAttachment].
  Future<Result<String>> previewAttachment(
    ChatAttachmentEntity attachment, {
    int? studentId,
    CancelHandle? cancel,
  });
}
