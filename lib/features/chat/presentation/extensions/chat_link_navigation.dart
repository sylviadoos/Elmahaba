import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_link_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';

extension ChatLinkNavigation on BuildContext {
  /// Opens the screen a chat item leads to: a tab, a complaint, or the
  /// homework of the link's child (else [studentId], the item's).
  void openChatLink(ChatLinkEntity link, {int? studentId}) =>
      GoRouter.of(this).openChatLink(link, studentId: studentId);
}

extension ChatLinkRouting on GoRouter {
  /// [ChatLinkNavigation.openChatLink] on the router itself, for a tapped
  /// notification: it is handled above `MaterialApp.router`, where
  /// `GoRouter.of(context)` can't reach it.
  void openChatLink(ChatLinkEntity link, {int? studentId}) {
    switch (link.screen) {
      case ChatScreen.attendance:
        go(AppRoutes.attendance);
      case ChatScreen.results:
        go(AppRoutes.results);
      case ChatScreen.fees:
        go(AppRoutes.fees);
      case ChatScreen.complaint:
        final complaintId = link.itemId;
        push(
          complaintId == null
              ? AppRoutes.complaints
              : AppRoutes.complaintDetailsOf(complaintId),
        );
      case ChatScreen.homework:
        push(AppRoutes.homework, extra: link.studentId ?? studentId);
      case ChatScreen.announcements:
        push(AppRoutes.announcements, extra: link.studentId ?? studentId);
    }
  }
}
