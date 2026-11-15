import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/bloc_effect_listener.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_effect.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_intent.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/widgets/announcements_header.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/widgets/announcements_list.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_file_opener.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

/// The school's announcements to a child's parents, newest first: each with
/// who it went to, its text, when it was published (and until when it
/// stands), and its files. Opened from Home ("View all"), on the child it
/// showed ([studentId]).
///
/// MVI: the widgets send [AnnouncementsIntent]s to the [AnnouncementsBloc]
/// and draw its state; this page runs its [AnnouncementsEffect]s.
class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key, this.studentId});

  /// The child shown first; the one every page shows without one.
  final int? studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AnnouncementsBloc>(),
      child: _AnnouncementsView(studentId: studentId),
    );
  }
}

class _AnnouncementsView extends StatefulWidget {
  const _AnnouncementsView({this.studentId});

  final int? studentId;

  @override
  State<_AnnouncementsView> createState() => _AnnouncementsViewState();
}

class _AnnouncementsViewState extends State<_AnnouncementsView> {
  @override
  void initState() {
    super.initState();
    _sendChildren(context.read<ChildrenViewModel>().state);
  }

  /// The announcements follow the parent's children, opening on the child
  /// Home showed, else the one every page shows.
  void _sendChildren(ChildrenState state) =>
      context.read<AnnouncementsBloc>().add(
        AnnouncementsChildrenIntent(
          state.children.data,
          isLoading: state.children.state == StateType.loading,
          preferredId: widget.studentId ?? state.selectedChild?.studentId,
        ),
      );

  void _onEffect(BuildContext context, AnnouncementsEffect effect) {
    switch (effect) {
      case OpenAnnouncementFileEffect(:final path, :final attachment):
        context.openChatFile(path, attachment);
      case ShowAnnouncementsErrorEffect(:final exception):
        context.showSnackBar(
          exception.localizedMessage(context),
          isError: true,
        );
        if (exception is UnauthorizedException) context.logOut();
      // Announcements read here come off the badge on Chat by itself
      // (`ChatUnreadBloc` follows every read the school confirms).
      case AnnouncementsChildPickedEffect(:final studentId):
        context.selectChild(studentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChildrenViewModel, ChildrenState>(
      listenWhen: (previous, current) => previous.children != current.children,
      listener: (_, state) => _sendChildren(state),
      child: BlocEffectListener<AnnouncementsBloc, AnnouncementsEffect>(
        listener: _onEffect,
        child: const AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: AppColors.surface,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnnouncementsHeader(),
                Expanded(child: AnnouncementsList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
