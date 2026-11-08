import 'package:al_mahhaba_school/core/error/app_exception.dart';

/// What happens once in the chat and isn't state, from `ChatBloc` to the
/// page.
sealed class ChatEffect {
  const ChatEffect();
}

/// The message went: empty the box, back to the newest.
final class MessageSentEffect extends ChatEffect {
  const MessageSentEffect();
}

/// The box is ready to type in (an answer was started).
final class FocusComposerEffect extends ChatEffect {
  const FocusComposerEffect();
}

/// A file downloaded, to open.
final class OpenFileEffect extends ChatEffect {
  const OpenFileEffect(this.path);

  final String path;
}

/// Something failed that the page says in a snack bar. An
/// [UnauthorizedException] also signs the parent out.
final class ShowErrorEffect extends ChatEffect {
  const ShowErrorEffect(this.exception);

  final AppException exception;
}

/// What's still unread in the whole chat, for the badge on Chat.
final class UnreadChangedEffect extends ChatEffect {
  const UnreadChangedEffect(this.count);

  final int count;
}

/// The parent picked the child with [studentId]: every page shows them now.
final class ChildPickedEffect extends ChatEffect {
  const ChildPickedEffect(this.studentId);

  final int studentId;
}
