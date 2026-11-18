import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/chat/data/models/chat_link_model.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';

void main() {
  test('an announcement opens Announcements, for its child', () {
    for (final screen in ['announcement', 'announcements']) {
      final link = ChatLinkModel.fromJson({
        'screen': screen,
        'student_id': 1208,
        'item_type': 'announcement',
        'item_id': 7,
      });

      expect(link?.screen, ChatScreen.announcements, reason: screen);
      expect(link?.studentId, 1208);
      expect(link?.itemId, 7);
    }
  });

  test('a screen the app doesn\'t have: no link', () {
    expect(ChatLinkModel.fromJson({'screen': 'library'}), isNull);
  });
}
