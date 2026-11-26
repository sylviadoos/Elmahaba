import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_loading.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_state.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_items_list.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';

/// The middle of the chat: loading, why it didn't load (with "Try again"),
/// "No messages yet", or the items.
class ChatTimeline extends StatelessWidget {
  const ChatTimeline({super.key, required this.scroll});

  /// The items' list, newest at offset 0.
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      // Not while the message is typed or a file downloads (its link shows
      // that itself).
      buildWhen: (previous, current) =>
          previous.chat != current.chat ||
          previous.isPullRefreshing != current.isPullRefreshing ||
          previous.noReply != current.noReply ||
          previous.studentId != current.studentId ||
          previous.children != current.children,
      builder: (context, state) {
        final l10n = context.l10n;
        final page = state.page;
        if (page == null) {
          final exception = state.chat.exception;
          if (exception == null) return const AppLoading();
          return CenteredStateMessage(
            icon: AppIcons.navChat,
            title: exception.localizedMessage(context),
            action: RetryOrLogInButton(
              exception: exception,
              onRetry: () =>
                  context.read<ChatBloc>().add(const RetryChatIntent()),
            ),
          );
        }
        if (page.items.isEmpty) {
          return CenteredStateMessage(
            icon: AppIcons.navChat,
            title: l10n.noMessagesYet,
            subtitle: l10n.noMessagesHint,
          );
        }
        return ChatItemsList(state: state, page: page, scroll: scroll);
      },
    );
  }
}
