import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_link_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';

/// The screen a notification the parent tapped leads to, from its `data` —
/// null for the chat.
///
/// Everything the school sends is in the chat as well: a message, a
/// result, an absence, a reply to a complaint. So a push that names no
/// screen this app has opens the chat, where what the parent tapped is.
/// Only one that names another screen goes elsewhere.
///
/// The `data` is what the school's push carries, in the words a chat
/// item's `related` uses:
/// `{"screen": "fees", "student_id": "1208", "item_id": "5521"}`
///
/// Firebase sends every value of `data` as text, even the ids, so numbers
/// are read from either ("1208" and 1208 both).
ChatLinkEntity? notificationLink(Map<String, dynamic> data) {
  // `type` as well: the same thing under another name.
  final named = data['screen'] ?? data['type'];
  final screen = switch (named is String ? named.trim().toLowerCase() : null) {
    'attendance' || 'absence' => ChatScreen.attendance,
    'results' || 'result' => ChatScreen.results,
    'fees' || 'fee' || 'payment' => ChatScreen.fees,
    'complaints' || 'complaint' => ChatScreen.complaint,
    'homework' => ChatScreen.homework,
    // "chat", "message", anything else, or nothing at all: the chat.
    _ => null,
  };
  if (screen == null) return null;
  return ChatLinkEntity(
    screen: screen,
    studentId: _id(data['student_id']),
    itemId: _id(data['item_id']),
  );
}

/// An id sent as a number or as text; null when it's neither.
int? _id(Object? value) => jsonDouble(value)?.toInt();
