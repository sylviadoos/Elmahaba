import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_shortcut_button.dart';

/// Fees, Results and Homework beside the chat's child picker, each opening
/// its page (Homework on the child shown, [studentId]); dotted when it's in
/// [withNews]. Attendance is in the nav bar.
class ChatShortcuts extends StatelessWidget {
  const ChatShortcuts({super.key, this.withNews = const {}, this.studentId});

  /// The pages the chat has unread news about.
  final Set<ChatScreen> withNews;

  /// The child the chat shows; null for all of them.
  final int? studentId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6.w,
      children: [
        ChatShortcutButton(
          icon: AppIcons.navFees,
          tooltip: l10n.fees,
          hasNews: withNews.contains(ChatScreen.fees),
          onTap: () => context.go(AppRoutes.fees),
        ),
        ChatShortcutButton(
          icon: AppIcons.navResults,
          tooltip: l10n.results,
          hasNews: withNews.contains(ChatScreen.results),
          onTap: () => context.go(AppRoutes.results),
        ),
        ChatShortcutButton(
          icon: AppIcons.book,
          tooltip: l10n.homework,
          hasNews: withNews.contains(ChatScreen.homework),
          onTap: () => context.push(AppRoutes.homework, extra: studentId),
        ),
      ],
    );
  }
}
