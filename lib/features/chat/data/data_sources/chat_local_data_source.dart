import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';

/// The newest page of each chat, kept in memory while the app runs: shown
/// at once when the chat (or a child) opens again, while it loads anew.
abstract interface class ChatLocalDataSource {
  /// The newest page of [studentId]'s chat (everything for null), as last
  /// loaded; null when it wasn't.
  ChatPageEntity? newestPage(int? studentId);

  void saveNewestPage(int? studentId, ChatPageEntity page);

  /// [keys] read in [studentId]'s kept page, [unread] left there: opened
  /// again, they don't show as new — nor are they marked read again.
  void markRead(int? studentId, Set<String> keys, {required int unread});

  /// Forgets every chat (log out: the next parent mustn't see them).
  void clear();
}
