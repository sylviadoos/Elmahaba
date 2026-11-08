import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// At the top of the chat when older items didn't load: why, and "Try
/// again".
class ChatOlderFailed extends StatelessWidget {
  const ChatOlderFailed({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Text(
          l10n.olderMessagesFailed,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(color: AppColors.slate),
        ),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.actionRed,
            minimumSize: Size(0, 36.h),
          ),
          child: Text(l10n.tryAgain),
        ),
      ],
    );
  }
}
