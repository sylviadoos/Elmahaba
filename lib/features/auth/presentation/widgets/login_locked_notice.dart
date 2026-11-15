import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// Above Log in while the number is locked: why, and the time [left]
/// counting down (04:59).
class LoginLockedNotice extends StatelessWidget {
  const LoginLockedNotice({super.key, required this.left});

  final Duration left;

  /// 04:59 — whole seconds, rounded up, so it ends on 00:01, not 00:00.
  static String format(Duration left) {
    final seconds = (left.inMilliseconds / 1000).ceil();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(seconds ~/ 60)}:${twoDigits(seconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        spacing: 10.w,
        children: [
          AppSvgIcon(AppIcons.lock, size: 20.r, color: AppColors.error),
          Expanded(
            child: Text(
              context.l10n.loginLockedFor(format(left).ltrIsolated),
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
                // The seconds change without the text moving.
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
