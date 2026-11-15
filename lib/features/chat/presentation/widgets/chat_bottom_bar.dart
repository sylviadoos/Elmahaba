import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_bottom_note.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_message_box.dart';

/// The bottom of the chat once it loaded: the message box, or why there's
/// none (no child enrolled, or the school closed the chat).
class ChatBottomBar extends StatelessWidget {
  const ChatBottomBar({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  /// The message box's.
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    // Just what it shows: comparing whole pages on every change is slow.
    final (canWrite, isOpen) = context.select(
      (ChatBloc bloc) => (bloc.state.canWrite, bloc.state.page?.isOpen),
    );
    if (canWrite) {
      return ChatMessageBox(controller: controller, focusNode: focusNode);
    }
    if (isOpen == null) return const SizedBox.shrink();
    // Closed by the school: the chat can still be read.
    return isOpen
        ? ChatBottomNote(icon: AppIcons.info, text: context.l10n.chatCantSend)
        : ChatBottomNote(icon: AppIcons.lock, text: context.l10n.chatClosed);
  }
}
