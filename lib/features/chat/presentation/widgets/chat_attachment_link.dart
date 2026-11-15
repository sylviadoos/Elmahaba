import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_bloc_image_source.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_attachment_kind.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_file_link.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_file_preview.dart';

/// A chat item's file, from the [ChatBloc]: a PDF's first page on top,
/// opens it (a PDF here, full screen), and shows it downloading (another
/// one waits meanwhile). Only this rebuilds as files download, not the
/// chat around it.
class ChatAttachmentLink extends StatelessWidget {
  const ChatAttachmentLink(this.attachment, {super.key, this.onRed = false});

  final ChatAttachmentEntity attachment;

  /// On the parent's red bubble.
  final bool onRed;

  @override
  Widget build(BuildContext context) {
    final downloadingId = context.select(
      (ChatBloc bloc) => bloc.state.downloadingId,
    );

    return ChatFileLink(
      attachment: attachment,
      isDownloading: downloadingId == attachment.id,
      onOpen: downloadingId == null
          ? () => context.read<ChatBloc>().add(OpenAttachmentIntent(attachment))
          : null,
      onRed: onRed,
      preview: attachment.isPdf
          ? ChatFilePreview(
              source: const ChatBlocImageSource(),
              attachment: attachment,
              onRed: onRed,
            )
          : null,
    );
  }
}
