import 'package:flutter/material.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// "Resend code in 0:45", with the time in bold.
class ResendCountdown extends StatelessWidget {
  const ResendCountdown({super.key, required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    // m:ss — 60 seconds is "1:00", not "0:60".
    final time =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    final text = context.l10n.resendCodeIn(time);
    final timeAt = text.indexOf(time);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, timeAt)),
          TextSpan(
            text: time,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          TextSpan(text: text.substring(timeAt + time.length)),
        ],
      ),
      style: context.textTheme.bodyMedium?.copyWith(
        height: 44 / 14,
        color: AppColors.slate,
      ),
    );
  }
}
