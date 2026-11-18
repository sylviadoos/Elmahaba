import 'dart:math' as math;

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
import 'package:al_mahhaba_school/features/announcements/presentation/announcement_args.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_effect.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_intent.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/widgets/announcement_card.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_file_opener.dart';

/// One announcement, on a page of its own: tapped on Home, in the chat, or
/// on a notification. The parent arrives holding it ([AnnouncementArgs]),
/// so nothing is loaded and the list isn't scrolled through to reach it —
/// which also keeps the announcements in between unread.
///
/// It still needs an [AnnouncementsBloc]: the card's photos and files come
/// from one, and seeing it is marked through it.
class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.args});

  final AnnouncementArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AnnouncementsBloc>()
            ..add(ShowOneAnnouncementIntent(args.studentId)),
      child: _AnnouncementView(args: args),
    );
  }
}

class _AnnouncementView extends StatefulWidget {
  const _AnnouncementView({required this.args});

  final AnnouncementArgs args;

  @override
  State<_AnnouncementView> createState() => _AnnouncementViewState();
}

class _AnnouncementViewState extends State<_AnnouncementView> {
  @override
  void initState() {
    super.initState();
    // Opened is seen: the chat item it came from goes off the badge, as it
    // would have in the list.
    final announcement = widget.args.announcement;
    final chatKey = announcement.chatKey;
    if (!announcement.isRead && chatKey != null) {
      context.read<AnnouncementsBloc>().add(AnnouncementSeenIntent(chatKey));
    }
  }

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
      // The child is never picked here: there's one announcement, and it
      // is the one the parent tapped.
      case AnnouncementsChildPickedEffect():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return BlocEffectListener<AnnouncementsBloc, AnnouncementsEffect>(
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
                    // Back to wherever it was tapped; Announcements when
                    // it was a notification and there's nothing under it.
                    const AppBackButton(fallbackRoute: AppRoutes.announcements),
                    Expanded(
                      child: Text(
                        l10n.announcement,
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
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    8.h,
                    20.w,
                    math.max(24.h, MediaQuery.paddingOf(context).bottom + 16),
                  ),
                  child: AnnouncementCard(widget.args.announcement),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
