import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';

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

/// [attachment] downloaded to [path], to open: a PDF here, full screen.
final class OpenFileEffect extends ChatEffect {
  const OpenFileEffect(this.path, this.attachment);

  final String path;
  final ChatAttachmentEntity attachment;
}

/// Something failed that the page says in a snack bar. An
/// [UnauthorizedException] also signs the parent out.
final class ShowErrorEffect extends ChatEffect {
  const ShowErrorEffect(this.exception);

  final AppException exception;
}

/// The parent picked the child with [studentId]: every page shows them now.
final class ChildPickedEffect extends ChatEffect {
  const ChildPickedEffect(this.studentId);

  final int studentId;
}
