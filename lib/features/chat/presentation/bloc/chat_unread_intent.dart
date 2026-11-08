/// What changes the badge on Chat, sent to `ChatUnreadBloc`.
sealed class ChatUnreadIntent {
  const ChatUnreadIntent();
}

/// Asks the server how many chat items are unread.
final class LoadChatUnreadIntent extends ChatUnreadIntent {
  const LoadChatUnreadIntent();
}

/// What the chat learned is unread, e.g. after marking items read.
final class SetChatUnreadIntent extends ChatUnreadIntent {
  const SetChatUnreadIntent(this.count);

  final int count;
}

/// Forgets the count, on log out.
final class ClearChatUnreadIntent extends ChatUnreadIntent {
  const ClearChatUnreadIntent();
}
