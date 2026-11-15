import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_attendance_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/message_counts_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/extensions/dashboard_chat_counts.dart';

/// A dashboard saying [messages] and [notices] are unread in the chat, and
/// listing so many unread announcements, homework and results.
ChildDashboardEntity _dashboard({
  int messages = 0,
  int notices = 0,
  int announcements = 0,
  int homework = 0,
  int results = 0,
}) => ChildDashboardEntity(
  attendance: const DashboardAttendanceEntity(),
  messages: MessageCountsEntity(
    messages: messages,
    notices: notices,
    total: messages + notices,
  ),
  announcements: LatestItemsEntity(unread: announcements),
  homework: LatestItemsEntity(unread: homework),
  results: LatestItemsEntity(unread: results),
);

void main() {
  test('an announcement unread, the chat counts saying 0: it counts', () {
    expect(_dashboard(announcements: 1).unreadChat, (
      messages: 0,
      notices: 1,
      total: 1,
    ));
  });

  test('the announcements, homework and results unread, with messages', () {
    expect(
      _dashboard(
        messages: 2,
        announcements: 1,
        homework: 2,
        results: 1,
      ).unreadChat,
      (messages: 2, notices: 4, total: 6),
    );
  });

  test('the chat counts right: theirs, not counted twice', () {
    expect(_dashboard(notices: 3, announcements: 1, homework: 2).unreadChat, (
      messages: 0,
      notices: 3,
      total: 3,
    ));
  });

  test('more notices than listed (older ones): the chat counts\'', () {
    expect(_dashboard(messages: 1, notices: 5, announcements: 1).unreadChat, (
      messages: 1,
      notices: 5,
      total: 6,
    ));
  });

  test('nothing unread: 0', () {
    expect(_dashboard().unreadChat, (messages: 0, notices: 0, total: 0));
  });
}
