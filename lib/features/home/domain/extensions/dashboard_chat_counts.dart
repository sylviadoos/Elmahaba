import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';

extension DashboardChatCounts on ChildDashboardEntity {
  /// What's unread in the child's chat, for the Chat card: the school's
  /// messages, and its notices — the announcements, homework and results it
  /// posted there.
  ///
  /// `messages.notices` has come back 0 while an announcement was unread
  /// in the same answer, so the notices are never fewer than the unread
  /// announcements, homework and results it lists.
  ({int messages, int notices, int total}) get unreadChat {
    final listed = announcements.unread + homework.unread + results.unread;
    final notices = messages.notices > listed ? messages.notices : listed;
    return (
      messages: messages.messages,
      notices: notices,
      total: messages.messages + notices,
    );
  }
}
