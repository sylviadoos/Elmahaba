import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_toast_type.dart';

/// A short message on a white card: a coloured square with the [type]'s
/// icon, the [title], an optional [detail] under it, and a close button.
/// Shown by `context.showSnackBar`.
class AppToast extends StatelessWidget {
  const AppToast({
    super.key,
    required this.title,
    this.detail,
    this.type = AppToastType.success,
    this.onClose,
  });

  final String title;
  final String? detail;
  final AppToastType type;

  /// The close button; none without it.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 6.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        spacing: 12.w,
        children: [
          Container(
            width: 30.r,
            height: 30.r,
            decoration: BoxDecoration(
              color: type.color,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(type.icon, size: 18.r, color: AppColors.white),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.h,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                if (detail case final detail?)
                  Text(
                    detail,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.slate,
                    ),
                  ),
              ],
            ),
          ),
          if (onClose case final onClose?)
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close_rounded, size: 16.r),
              color: AppColors.mist,
              visualDensity: VisualDensity.compact,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
        ],
      ),
    );
  }
}
