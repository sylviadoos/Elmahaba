import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_file_link.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_bloc.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_intent.dart';

/// A homework file, from the [HomeworkBloc]: opens it, and shows it
/// downloading (another one waits meanwhile). Only this rebuilds as files
/// download, not the list around it.
class HomeworkFileLink extends StatelessWidget {
  const HomeworkFileLink(this.attachment, {super.key});

  final ChatAttachmentEntity attachment;

  @override
  Widget build(BuildContext context) {
    final downloadingId = context.select(
      (HomeworkBloc bloc) => bloc.state.downloadingId,
    );

    return ChatFileLink(
      attachment: attachment,
      isDownloading: downloadingId == attachment.id,
      onOpen: downloadingId == null
          ? () => context.read<HomeworkBloc>().add(
              OpenHomeworkFileIntent(attachment),
            )
          : null,
    );
  }
}
