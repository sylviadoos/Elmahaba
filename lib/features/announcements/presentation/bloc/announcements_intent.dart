import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';

/// What the parent does on Announcements, sent to `AnnouncementsBloc`.
sealed class AnnouncementsIntent {
  const AnnouncementsIntent();
}

/// The parent's children, as the app has them now: when the page opens,
/// then each time they change. It shows [preferredId]'s announcements at
/// first (the child Home showed), else the first child's.
final class AnnouncementsChildrenIntent extends AnnouncementsIntent {
  const AnnouncementsChildrenIntent(
    this.children, {
    required this.isLoading,
    this.preferredId,
  });

  /// Null until they first load.
  final List<ChildEntity>? children;
  final bool isLoading;
  final int? preferredId;
}

/// Shows the announcements of the child with [studentId], picked in the
/// header: every page shows them too.
final class ShowChildAnnouncementsIntent extends AnnouncementsIntent {
  const ShowChildAnnouncementsIntent(this.studentId);

  final int studentId;
}

/// Loads them all again: "Try again", or pulled down.
final class ReloadAnnouncementsIntent extends AnnouncementsIntent {
  const ReloadAnnouncementsIntent();
}

/// Loads the next page (the list scrolled near its end).
final class LoadMoreAnnouncementsIntent extends AnnouncementsIntent {
  const LoadMoreAnnouncementsIntent();
}

/// An unread announcement came on screen: its chat item is marked read
/// (with the others seen about then, in one request).
final class AnnouncementSeenIntent extends AnnouncementsIntent {
  const AnnouncementSeenIntent(this.chatKey);

  final String chatKey;
}

/// Downloads an announcement's file, to open it.
final class OpenAnnouncementFileIntent extends AnnouncementsIntent {
  const OpenAnnouncementFileIntent(this.attachment);

  final ChatAttachmentEntity attachment;
}

/// An announcement's photo came on screen, or "Try again" on one that
/// didn't load: it's saved on the phone to show. Nothing when it's saved or
/// on its way already.
final class LoadAnnouncementImageIntent extends AnnouncementsIntent {
  const LoadAnnouncementImageIntent(this.attachment);

  final ChatAttachmentEntity attachment;
}

/// The page of one announcement opened: whose it is, so seeing it is
/// marked for the right child. Nothing is loaded — the parent came with
/// the announcement in hand, from Home or the chat.
final class ShowOneAnnouncementIntent extends AnnouncementsIntent {
  const ShowOneAnnouncementIntent(this.studentId);

  final int? studentId;
}
