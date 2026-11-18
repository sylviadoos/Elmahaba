import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/announcements/presentation/extensions/open_announcement.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_link_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_sender.dart';

import '../../announcements_fixtures.dart';

void main() {
  ChatItemEntity item({bool titled = true}) => ChatItemEntity(
    key: 'event:40',
    sender: ChatSender.school,
    sentAt: DateTime.utc(2026, 11, 7, 8),
    title: titled ? 'Parents meeting' : null,
    text: 'Parents meeting on Sunday at 10 AM.',
    attachments: const [agendaFile],
    audience: meeting.audience,
    isRead: false,
    isEdited: false,
    isDeleted: false,
    canReply: false,
  );

  const toAnnouncement = ChatLinkEntity(
    screen: ChatScreen.announcements,
    itemId: 9,
  );

  group('the chat item as the announcement it leads to', () {
    test('is the announcement itself: nothing is loaded for it', () {
      // Field for field what the list would have shown.
      expect(chatItemAnnouncement(item(), toAnnouncement), meeting);
    });

    test('the chat item it came from, to mark it read by', () {
      expect(chatItemAnnouncement(item(), toAnnouncement)?.chatKey, 'event:40');
    });

    test('no title: the body still opens', () {
      final announcement = chatItemAnnouncement(
        item(titled: false),
        toAnnouncement,
      );

      expect(announcement?.title, '');
      expect(announcement?.body, 'Parents meeting on Sunday at 10 AM.');
    });
  });

  group('not an announcement to open', () {
    test('a link to another screen', () {
      expect(
        chatItemAnnouncement(
          item(),
          const ChatLinkEntity(screen: ChatScreen.homework, itemId: 9),
        ),
        isNull,
      );
    });

    test('an announcement the school named no id for', () {
      expect(
        chatItemAnnouncement(
          item(),
          const ChatLinkEntity(screen: ChatScreen.announcements),
        ),
        isNull,
      );
    });
  });
}
