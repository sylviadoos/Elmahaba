import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';

/// What happens once on Homework and isn't state, from `HomeworkBloc` to
/// the page.
sealed class HomeworkEffect {
  const HomeworkEffect();
}

/// [attachment] downloaded to [path], to open: a PDF here, full screen.
final class OpenHomeworkFileEffect extends HomeworkEffect {
  const OpenHomeworkFileEffect(this.path, this.attachment);

  final String path;
  final ChatAttachmentEntity attachment;
}

/// Something failed that the page says in a snack bar. An
/// [UnauthorizedException] also signs the parent out.
final class ShowHomeworkErrorEffect extends HomeworkEffect {
  const ShowHomeworkErrorEffect(this.exception);

  final AppException exception;
}

/// What's still unread in the whole chat (homework is in it), for the
/// badge on Chat.
final class ChatUnreadChangedEffect extends HomeworkEffect {
  const ChatUnreadChangedEffect(this.count);

  final int count;
}

/// The parent picked the child with [studentId]: every page shows them now.
final class HomeworkChildPickedEffect extends HomeworkEffect {
  const HomeworkChildPickedEffect(this.studentId);

  final int studentId;
}
