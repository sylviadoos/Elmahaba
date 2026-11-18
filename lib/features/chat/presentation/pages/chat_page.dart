import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/bloc_effect_listener.dart';
import 'package:al_mahhaba_school/core/widgets/page_refresher.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_effect.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_file_opener.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_bottom_bar.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_page_header.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_timeline.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

/// Everything between the parent and the school, newest at the bottom: the
/// school's messages and what it recorded (absences, results, fees…) for
/// the child picked (or all of them, in one chat) and for all parents, and
/// the parent's messages. Older items load while scrolling up. The parent
/// writes about the child picked (with all of them shown, about the one
/// picked above the box, or none); "Reply" on an item that takes one
/// quotes it in the box. Beside the picker, Fees, Results and Attendance
/// are a tap away, dotted when unread items are about them.
///
/// MVI: the widgets send [ChatIntent]s to the [ChatBloc] and draw its
/// state; this page runs its [ChatEffect]s.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatBloc>(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _message = TextEditingController();
  final FocusNode _messageFocus = FocusNode();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _sendChildren(context.read<ChildrenViewModel>().state);
  }

  @override
  void dispose() {
    _message.dispose();
    _messageFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// The chat follows the parent's children, opening on the one every page
  /// shows.
  void _sendChildren(ChildrenState state) => context.read<ChatBloc>().add(
    ChildrenChangedIntent(
      state.children.data,
      isLoading: state.children.state == StateType.loading,
      selectedId: state.selectedChild?.studentId,
    ),
  );

  void _onEffect(BuildContext context, ChatEffect effect) {
    switch (effect) {
      case MessageSentEffect():
        _message.clear();
        _scrollToNewest();
      case FocusComposerEffect():
        _messageFocus.requestFocus();
      case OpenFileEffect(:final path, :final attachment):
        context.openChatFile(path, attachment);
      case ShowErrorEffect(:final exception):
        context.showSnackBar(
          exception.localizedMessage(context),
          isError: true,
        );
        if (exception is UnauthorizedException) context.logOut();
      // What's read here comes off the badge on Chat by itself
      // (`ChatUnreadBloc` follows every read the school confirms).
      case ChildPickedEffect(:final studentId):
        context.selectChild(studentId);
    }
  }

  /// To the newest, where the message sent is.
  void _scrollToNewest() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChildrenViewModel, ChildrenState>(
          listenWhen: (previous, current) =>
              previous.children != current.children,
          listener: (_, state) => _sendChildren(state),
        ),
        // Picked on another page (Homework, from here).
        BlocListener<ChildrenViewModel, ChildrenState>(
          listenWhen: (previous, current) =>
              previous.selectedId != current.selectedId &&
              current.selectedId != null,
          listener: (context, state) => context.read<ChatBloc>().add(
            SelectedChildChangedIntent(state.selectedId!),
          ),
        ),
      ],
      child: BlocEffectListener<ChatBloc, ChatEffect>(
        listener: _onEffect,
        // The school's answers show as they come: a notification while the
        // chat is open, the app back to the front, back from a page opened
        // over it.
        child: PageRefresher(
          path: AppRoutes.chat,
          onRefresh: () =>
              context.read<ChatBloc>().add(const RefreshChatIntent()),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
              backgroundColor: AppColors.surface,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ChatPageHeader(),
                  Expanded(child: ChatTimeline(scroll: _scroll)),
                  ChatBottomBar(controller: _message, focusNode: _messageFocus),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
