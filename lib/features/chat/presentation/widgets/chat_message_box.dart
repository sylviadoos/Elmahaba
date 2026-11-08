import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_state.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_labels.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_composer.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_recipients.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_picker.dart';

/// The [ChatComposer] from the [ChatBloc]: with all children shown, whom
/// the message is about; what it answers; the files; why it wasn't sent.
class ChatMessageBox extends StatelessWidget {
  const ChatMessageBox({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  Future<void> _pickAttachments(
    BuildContext context,
    List<PickedAttachment> current,
  ) async {
    final files = await context.pickComplaintAttachments(current: current);
    // Left the chat meanwhile.
    if (!context.mounted) return;
    context.read<ChatBloc>().add(AddAttachmentsIntent(files));
  }

  /// The first field the school refused, or what went wrong.
  static String _errorText(BuildContext context, AppException exception) {
    final fieldErrors = exception is ServerException
        ? exception.fieldErrors
        : const <String, String>{};
    return fieldErrors.values.firstOrNull ??
        exception.localizedMessage(context);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChatBloc>();

    return BlocBuilder<ChatBloc, ChatState>(
      // Not while the message is typed: the box shows it itself.
      buildWhen: (previous, current) =>
          previous.showsAll != current.showsAll ||
          previous.children != current.children ||
          previous.aboutId != current.aboutId ||
          previous.replyingTo != current.replyingTo ||
          previous.attachments != current.attachments ||
          previous.isSending != current.isSending ||
          previous.upload != current.upload ||
          previous.canSendMessage != current.canSendMessage ||
          previous.sendError != current.sendError,
      builder: (context, state) {
        final sendError = state.sendError;
        final attachments = state.attachments;

        return ChatComposer(
          recipients: state.showsAll
              ? ChatRecipients(
                  children: state.children,
                  selected: state.aboutId,
                  onSelected: (id) => bloc.add(PickRecipientIntent(id)),
                  enabled: !state.isSending,
                )
              : null,
          replyingTo: state.replyingTo?.snippet(context),
          onCancelReply: () => bloc.add(const CancelReplyIntent()),
          controller: controller,
          focusNode: focusNode,
          attachments: attachments,
          upload: state.isSending
              ? state.upload ?? (sent: 0, total: attachments.validBytes)
              : null,
          isSending: state.isSending,
          errorText: sendError == null ? null : _errorText(context, sendError),
          onChanged: (text) => bloc.add(EditDraftIntent(text)),
          onAttach: state.canAttachMore
              ? () => _pickAttachments(context, attachments)
              : null,
          onRemoveAttachment: (index) =>
              bloc.add(RemoveAttachmentIntent(index)),
          onSend: state.canSendMessage
              ? () => bloc.add(const SendMessageIntent())
              : null,
        );
      },
    );
  }
}
