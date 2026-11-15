import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// Whether the parent had read a school item when the chat opened: a gold
/// "New" pill, or a quiet "✓ Read".
class ChatReadMark extends StatelessWidget {
  const ChatReadMark({super.key, required this.isRead});

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = context.textTheme.bodySmall?.copyWith(
      fontSize: 11.sp,
      height: 1.3,
      fontWeight: FontWeight.w700,
    );

    if (isRead) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 3.w,
        children: [
          AppSvgIcon(AppIcons.check, size: 13.r, color: AppColors.mist),
          Text(l10n.chatRead, style: style?.copyWith(color: AppColors.mist)),
        ],
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: const ShapeDecoration(
        color: AppColors.gold,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4.w,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.goldText,
            ),
          ),
          Text(l10n.chatNew, style: style?.copyWith(color: AppColors.goldText)),
        ],
      ),
    );
  }
}
