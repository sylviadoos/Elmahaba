import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/bloc_effect_listener.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_file_opener.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_bloc.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_effect.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_intent.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_header.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_list.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_subjects_bar.dart';

/// A child's homework, newest given first: all of it, or by when it's due
/// and by subject; each with what to do, its due date and its files. Opened
/// from the chat, on the child it showed ([studentId]).
///
/// MVI: the widgets send [HomeworkIntent]s to the [HomeworkBloc] and draw
/// its state; this page runs its [HomeworkEffect]s.
class HomeworkPage extends StatelessWidget {
  const HomeworkPage({super.key, this.studentId});

  /// The child shown first; the first child without one.
  final int? studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeworkBloc>(),
      child: _HomeworkView(studentId: studentId),
    );
  }
}

class _HomeworkView extends StatefulWidget {
  const _HomeworkView({this.studentId});

  final int? studentId;

  @override
  State<_HomeworkView> createState() => _HomeworkViewState();
}

class _HomeworkViewState extends State<_HomeworkView> {
  @override
  void initState() {
    super.initState();
    _sendChildren(context.read<ChildrenViewModel>().state);
  }

  /// The homework follows the parent's children, opening on the child it
  /// was opened on, else the one every page shows.
  void _sendChildren(ChildrenState state) => context.read<HomeworkBloc>().add(
    HomeworkChildrenIntent(
      state.children.data,
      isLoading: state.children.state == StateType.loading,
      preferredId: widget.studentId ?? state.selectedChild?.studentId,
    ),
  );

  void _onEffect(BuildContext context, HomeworkEffect effect) {
    switch (effect) {
      case OpenHomeworkFileEffect(:final path, :final attachment):
        context.openChatFile(path, attachment);
      case ShowHomeworkErrorEffect(:final exception):
        context.showSnackBar(
          exception.localizedMessage(context),
          isError: true,
        );
        if (exception is UnauthorizedException) context.logOut();
      // Homework read here comes off the badge on Chat.
      case ChatUnreadChangedEffect(:final count):
        context.read<ChatUnreadBloc>().add(SetChatUnreadIntent(count));
      case HomeworkChildPickedEffect(:final studentId):
        context.selectChild(studentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChildrenViewModel, ChildrenState>(
      listenWhen: (previous, current) => previous.children != current.children,
      listener: (_, state) => _sendChildren(state),
      child: BlocEffectListener<HomeworkBloc, HomeworkEffect>(
        listener: _onEffect,
        child: const AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: AppColors.surface,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeworkHeader(),
                HomeworkSubjectsBar(),
                Expanded(child: HomeworkList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
