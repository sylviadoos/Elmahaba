import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/notifications/notification_link.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';

void main() {
  group('the chat, where everything the school sends is', () {
    test('a message: it names no screen', () {
      expect(notificationLink(const {'type': 'message'}), isNull);
    });

    test('a push with nothing in it at all', () {
      expect(notificationLink(const {}), isNull);
    });

    test('a screen this app does not have', () {
      expect(notificationLink(const {'screen': 'library'}), isNull);
    });

    test('"chat" itself', () {
      expect(notificationLink(const {'screen': 'chat'}), isNull);
    });
  });

  group('a screen the push names', () {
    test('as `screen`, the word a chat item uses', () {
      expect(
        notificationLink(const {'screen': 'fees'})?.screen,
        ChatScreen.fees,
      );
    });

    test('as `type`: the same thing under another name', () {
      expect(
        notificationLink(const {'type': 'attendance'})?.screen,
        ChatScreen.attendance,
      );
    });

    test('whatever its spelling or case', () {
      for (final (named, screen) in [
        ('result', ChatScreen.results),
        ('results', ChatScreen.results),
        ('Fee', ChatScreen.fees),
        ('PAYMENT', ChatScreen.fees),
        ('complaint', ChatScreen.complaint),
        ('complaints', ChatScreen.complaint),
        (' homework ', ChatScreen.homework),
        ('absence', ChatScreen.attendance),
        ('announcement', ChatScreen.announcements),
        ('Announcements', ChatScreen.announcements),
      ]) {
        expect(
          notificationLink({'screen': named})?.screen,
          screen,
          reason: named,
        );
      }
    });
  });

  group('the ids, which Firebase sends as text', () {
    test('a complaint: its id opens it', () {
      final link = notificationLink(const {
        'screen': 'complaints',
        'item_id': '5521',
        'student_id': '1208',
      });

      expect(link?.itemId, 5521);
      expect(link?.studentId, 1208);
    });

    test('sent as numbers all the same', () {
      final link = notificationLink(const {
        'screen': 'homework',
        'item_id': 41,
        'student_id': 1208,
      });

      expect(link?.itemId, 41);
      expect(link?.studentId, 1208);
    });

    test('missing or not a number: the screen opens without them', () {
      final link = notificationLink(const {
        'screen': 'homework',
        'student_id': '',
      });

      expect(link?.screen, ChatScreen.homework);
      expect(link?.studentId, isNull);
      expect(link?.itemId, isNull);
    });
  });
}
