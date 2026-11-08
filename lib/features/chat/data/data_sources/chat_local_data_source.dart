import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';

/// The newest page of each chat, kept in memory while the app runs: shown
/// at once when the chat (or a child) opens again, while it loads anew.
abstract interface class ChatLocalDataSource {
  /// The newest page of [studentId]'s chat (everything for null), as last
  /// loaded; null when it wasn't.
  ChatPageEntity? newestPage(int? studentId);

  void saveNewestPage(int? studentId, ChatPageEntity page);

  /// Forgets every chat (log out: the next parent mustn't see them).
  void clear();
}
