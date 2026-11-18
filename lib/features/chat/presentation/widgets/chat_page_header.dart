import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_state.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_header.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_shortcuts.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_picker.dart';

/// The chat's [ChatHeader] from the [ChatBloc]: the child picker (with
/// "All" for two or more, dotted when the others have unread items) and the
/// shortcuts, dotted for what's unread.
class ChatPageHeader extends StatelessWidget {
  const ChatPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      // Not for every change in the chat: its dots are worked out as it
      // loads.
      buildWhen: (previous, current) =>
          previous.children != current.children ||
          previous.studentId != current.studentId ||
          previous.screensWithNews != current.screensWithNews ||
          previous.othersUnread != current.othersUnread,
      builder: (context, state) {
        final children = state.children;
        final shown = state.shownIndex;

        return ChatHeader(
          picker: children.isEmpty
              ? null
              : ChildPicker(
                  children: children,
                  selected: state.showsAll
                      ? ChildPicker.all
                      : shown < 0
                      ? 0
                      : shown,
                  withAll: children.length > 1,
                  compact: true,
                  hasNews: state.othersUnread,
                  onSelected: (index) => context.read<ChatBloc>().add(
                    ShowChildChatIntent(
                      index == ChildPicker.all
                          ? null
                          : children[index].studentId,
                    ),
                  ),
                ),
          shortcuts: children.isEmpty
              ? null
              : ChatShortcuts(
                  withNews: state.screensWithNews,
                  studentId: state.studentId,
                ),
        );
      },
    );
  }
}
