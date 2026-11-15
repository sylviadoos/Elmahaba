import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/features/announcements/presentation/announcement_image_source.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_intent.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_attachment_kind.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_file_link.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_file_preview.dart';

/// An announcement's file, from the [AnnouncementsBloc]: a PDF's first page
/// on top, opens it (a PDF here, full screen), and shows it downloading
/// (another one waits meanwhile). Only this rebuilds as files download.
class AnnouncementFileLink extends StatelessWidget {
  const AnnouncementFileLink(this.attachment, {super.key});

  final ChatAttachmentEntity attachment;

  @override
  Widget build(BuildContext context) {
    final downloadingId = context.select(
      (AnnouncementsBloc bloc) => bloc.state.downloadingId,
    );

    return ChatFileLink(
      attachment: attachment,
      isDownloading: downloadingId == attachment.id,
      onOpen: downloadingId == null
          ? () => context.read<AnnouncementsBloc>().add(
              OpenAnnouncementFileIntent(attachment),
            )
          : null,
      preview: attachment.isPdf
          ? ChatFilePreview(
              source: const AnnouncementImageSource(),
              attachment: attachment,
            )
          : null,
    );
  }
}
