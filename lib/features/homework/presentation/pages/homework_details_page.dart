import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/bloc_effect_listener.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_file_opener.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_bloc.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_effect.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_intent.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_state.dart';
import 'package:al_mahhaba_school/features/homework/presentation/homework_args.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_details_body.dart';

/// One homework, on a page of its own: tapped on Home, in the chat, or on
/// a notification. From Home the parent arrives holding it
/// ([HomeworkArgs.homework]), so nothing is loaded; from the chat it's
/// found by [homeworkId]. Either way the list isn't scrolled through to
/// reach it — which also keeps the homework in between unread.
///
/// It still needs a [HomeworkBloc]: the card's photos and files come from
/// one, and seeing it is marked through it.
class HomeworkDetailsPage extends StatelessWidget {
  const HomeworkDetailsPage({
    super.key,
    required this.homeworkId,
    this.args = const HomeworkArgs(),
  });

  final int homeworkId;
  final HomeworkArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeworkBloc>(),
      child: _HomeworkDetailsView(homeworkId: homeworkId, args: args),
    );
  }
}

class _HomeworkDetailsView extends StatefulWidget {
  const _HomeworkDetailsView({required this.homeworkId, required this.args});

  final int homeworkId;
  final HomeworkArgs args;

  @override
  State<_HomeworkDetailsView> createState() => _HomeworkDetailsViewState();
}

class _HomeworkDetailsViewState extends State<_HomeworkDetailsView> {
  @override
  void initState() {
    super.initState();
    _show();
  }

  /// Shown as it came, or looked for — the child's it's about, else the one
  /// every page shows. Again on "Try again".
  void _show() {
    final studentId =
        widget.args.studentId ??
        context.read<ChildrenViewModel>().state.selectedChild?.studentId;
    context.read<HomeworkBloc>().add(
      ShowOneHomeworkIntent(
        studentId: studentId,
        homeworkId: widget.homeworkId,
        homework: widget.args.homework,
      ),
    );
  }

  /// Opened is seen: the chat item it came from goes off the badge, as it
  /// would have in the list.
  void _onShown(BuildContext context, HomeworkState state) {
    final homework = state.one.data;
    final chatKey = homework?.chatKey;
    if (homework == null || homework.isRead || chatKey == null) return;
    context.read<HomeworkBloc>().add(HomeworkSeenIntent(chatKey));
  }

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
      // The child is never picked here: there's one homework, and it is
      // the one the parent tapped.
      case HomeworkChildPickedEffect():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return BlocListener<HomeworkBloc, HomeworkState>(
      listenWhen: (previous, current) =>
          previous.one.data != current.one.data &&
          current.one.data is HomeworkEntity,
      listener: _onShown,
      child: BlocEffectListener<HomeworkBloc, HomeworkEffect>(
        listener: _onEffect,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: AppColors.surface,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RedHeader(
                  horizontalPadding: 16,
                  bottomPadding: 40,
                  watermarkTop: 20,
                  watermarkSize: const Size(200, 143),
                  child: Row(
                    spacing: 10.w,
                    children: [
                      // Back to wherever it was tapped; Homework when it
                      // was a notification and there's nothing under it.
                      const AppBackButton(fallbackRoute: AppRoutes.homework),
                      Expanded(
                        child: Text(
                          l10n.homeworkOne,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24.sp,
                            height: 28 / 24,
                            letterSpacing: 0,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: HomeworkDetailsBody(onRetry: _show)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
