/// What changes the badge on Chat, sent to `ChatUnreadBloc`.
sealed class ChatUnreadIntent {
  const ChatUnreadIntent();
}

/// Asks the school what's new for the child with [studentId] (the one
/// every page shows), as the School chat card on Home counts it.
final class LoadChatUnreadIntent extends ChatUnreadIntent {
  const LoadChatUnreadIntent(this.studentId);

  final int studentId;
}

/// The School chat card's count, as Home just loaded it.
final class SetChatUnreadIntent extends ChatUnreadIntent {
  const SetChatUnreadIntent(this.count);

  final int count;
}

/// Home opened (it stays open under the other tabs and pages): it loads
/// the dashboard again after every read and sets the count from it, so the
/// badge doesn't ask for the very same dashboard too.
final class HomeOpenedIntent extends ChatUnreadIntent {
  const HomeOpenedIntent();
}

/// Home closed (signed out, say): the badge asks after reads itself again.
final class HomeClosedIntent extends ChatUnreadIntent {
  const HomeClosedIntent();
}

/// Forgets the count, on log out.
final class ClearChatUnreadIntent extends ChatUnreadIntent {
  const ClearChatUnreadIntent();
}
