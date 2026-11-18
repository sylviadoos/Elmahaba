import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/announcement_args.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_link_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';

extension OpenAnnouncement on BuildContext {
  /// Opens [announcement] on a page of its own, over what the parent was
  /// looking at. It goes with it: the school isn't asked for it again.
  void openAnnouncement(AnnouncementEntity announcement, {int? studentId}) =>
      push(
        AppRoutes.announcementDetailsOf(announcement.id),
        extra: AnnouncementArgs(announcement, studentId: studentId),
      );
}

/// The announcement a chat item leads to, as the item itself has it: the
/// chat carries the title, the text, the files and who it went to — all
/// the page shows — so it opens with nothing loaded.
///
/// Null when [link] leads elsewhere, or names no announcement: that one
/// opens Announcements, as before.
AnnouncementEntity? chatItemAnnouncement(
  ChatItemEntity item,
  ChatLinkEntity link,
) {
  if (link.screen != ChatScreen.announcements) return null;
  final id = link.itemId;
  if (id == null) return null;

  return AnnouncementEntity(
    id: id,
    title: item.title ?? '',
    body: item.text,
    publishedAt: item.sentAt,
    isEdited: item.isEdited,
    attachments: item.attachments,
    audience: item.audience,
    chatKey: item.key,
    isRead: item.isRead,
  );
}
