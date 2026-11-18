import 'package:al_mahhaba_school/features/chat/domain/entities/chat_link_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';

class ChatLinkModel extends ChatLinkEntity {
  const ChatLinkModel({required super.screen, super.studentId, super.itemId});

  /// The item's `related`: { "screen": "attendance", "student_id": 1208,
  ///   "item_type": "attendance", "item_id": 5521 }
  ///
  /// Null for a screen this app doesn't have.
  static ChatLinkModel? fromJson(Map<String, dynamic> json) {
    // "attendance" and "homework" seen so far; the others as the app names
    // them.
    final screen = switch (json['screen']) {
      'attendance' => ChatScreen.attendance,
      'results' || 'result' => ChatScreen.results,
      'fees' || 'fee' => ChatScreen.fees,
      'complaints' || 'complaint' => ChatScreen.complaint,
      'homework' => ChatScreen.homework,
      'announcements' || 'announcement' => ChatScreen.announcements,
      _ => null,
    };
    if (screen == null) return null;
    return ChatLinkModel(
      screen: screen,
      studentId: json['student_id'] as int?,
      itemId: json['item_id'] as int?,
    );
  }
}
