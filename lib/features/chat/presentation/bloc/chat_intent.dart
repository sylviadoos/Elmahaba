import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_picker.dart';

/// What the parent does in the chat, sent to `ChatBloc`.
sealed class ChatIntent {
  const ChatIntent();
}

/// The parent's children, as the app has them now: when the chat opens,
/// then each time they change. The chat shows [selectedId]'s (the child
/// every page shows), else the first one's (all of them, with two or more,
/// once one is unlinked), once they're here.
final class ChildrenChangedIntent extends ChatIntent {
  const ChildrenChangedIntent(
    this.children, {
    required this.isLoading,
    this.selectedId,
  });

  /// Null until they first load.
  final List<ChildEntity>? children;
  final bool isLoading;
  final int? selectedId;
}

/// Another child was picked on another page (Homework, from the chat): the
/// chat shows the child with [studentId] too.
final class SelectedChildChangedIntent extends ChatIntent {
  const SelectedChildChangedIntent(this.studentId);

  final int studentId;
}

/// Shows the chat of the child with [studentId]; null for all of them. A
/// child picked here is shown on every page.
final class ShowChildChatIntent extends ChatIntent {
  const ShowChildChatIntent(this.studentId);

  final int? studentId;
}

/// Loads the chat shown again, after it failed.
final class RetryChatIntent extends ChatIntent {
  const RetryChatIntent();
}

/// The chat may have news (a notification came while it's open, the app
/// came back to the front…): the newest items are asked for again and
/// join what's shown, quietly — no spinner, the message being written
/// stays.
final class RefreshChatIntent extends ChatIntent {
  const RefreshChatIntent();
}

/// The parent pulled past the newest item: the same, but a spinner shows
/// under it until the answer is in, and a snack bar says why when it
/// didn't come.
final class PullRefreshChatIntent extends ChatIntent {
  const PullRefreshChatIntent();
}

/// Loads the items before the oldest shown (the parent scrolled up to it).
final class LoadOlderChatIntent extends ChatIntent {
  const LoadOlderChatIntent();
}

/// An unread item came on screen: it's marked read (with the others seen
/// about then, in one request).
final class ItemSeenIntent extends ChatIntent {
  const ItemSeenIntent(this.key);

  /// The item's `key`.
  final String key;
}

/// The items under [keys] are read on screen ([isRead]), or unread again
/// when telling the school failed; [unread] is what the school says is
/// left in the whole chat. Sent by the bloc itself, as it marks them.
final class ItemsReadChangedIntent extends ChatIntent {
  const ItemsReadChangedIntent(this.keys, {required this.isRead, this.unread});

  final Set<String> keys;
  final bool isRead;
  final int? unread;
}

/// With all children shown: the message is about the child with
/// [studentId]; null for none of them (a general message).
final class PickRecipientIntent extends ChatIntent {
  const PickRecipientIntent(this.studentId);

  final int? studentId;
}

/// "Reply" on [item]: the message answers it.
final class StartReplyIntent extends ChatIntent {
  const StartReplyIntent(this.item);

  final ChatItemEntity item;
}

final class CancelReplyIntent extends ChatIntent {
  const CancelReplyIntent();
}

/// The message box now says [text].
final class EditDraftIntent extends ChatIntent {
  const EditDraftIntent(this.text);

  final String text;
}

/// Files picked to send with the message.
final class AddAttachmentsIntent extends ChatIntent {
  const AddAttachmentsIntent(this.files);

  final List<PickedAttachment> files;
}

/// The file at [index] of those picked is taken out.
final class RemoveAttachmentIntent extends ChatIntent {
  const RemoveAttachmentIntent(this.index);

  final int index;
}

/// "Send": the draft, the files picked and what it answers.
final class SendMessageIntent extends ChatIntent {
  const SendMessageIntent();
}

/// Downloads a file shown, to open it.
final class OpenAttachmentIntent extends ChatIntent {
  const OpenAttachmentIntent(this.attachment);

  final ChatAttachmentEntity attachment;
}

/// A photo came on screen, or "Try again" on one that didn't load: it's
/// saved on the phone to show in the chat. Nothing when it's saved or on
/// its way already.
final class LoadImageIntent extends ChatIntent {
  const LoadImageIntent(this.attachment);

  final ChatAttachmentEntity attachment;
}
