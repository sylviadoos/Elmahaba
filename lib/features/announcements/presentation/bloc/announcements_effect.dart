import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';

/// What happens once on Announcements and isn't state, from
/// `AnnouncementsBloc` to the page.
sealed class AnnouncementsEffect {
  const AnnouncementsEffect();
}

/// [attachment] downloaded to [path], to open: a PDF here, full screen.
final class OpenAnnouncementFileEffect extends AnnouncementsEffect {
  const OpenAnnouncementFileEffect(this.path, this.attachment);

  final String path;
  final ChatAttachmentEntity attachment;
}

/// Something failed that the page says in a snack bar. An
/// [UnauthorizedException] also signs the parent out.
final class ShowAnnouncementsErrorEffect extends AnnouncementsEffect {
  const ShowAnnouncementsErrorEffect(this.exception);

  final AppException exception;
}

/// The parent picked the child with [studentId]: every page shows them now.
final class AnnouncementsChildPickedEffect extends AnnouncementsEffect {
  const AnnouncementsChildPickedEffect(this.studentId);

  final int studentId;
}
