import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';

/// A day that wasn't a plain school day — absent, late, excused or a
/// holiday — in the calendar's colors. [onAction] adds a button labelled
/// [actionLabel], e.g. "Submit excuse", or "Reply" for an absence the
/// school still needs a reason for.
class AttendanceEventRow extends StatelessWidget {
  const AttendanceEventRow({
    super.key,
    required this.date,
    required this.title,
    required this.detail,
    required this.background,
    required this.foreground,
    this.actionLabel,
    this.onAction,
  });

  final DateTime date;
  final String title;
  final String detail;
  final Color background;
  final Color foreground;

  /// "Reply" when null.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final locale = Localizations.localeOf(context).toString();
    final onAction = this.onAction;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        spacing: 12.w,
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd', locale).format(date),
                  style: textTheme.bodyLarge?.copyWith(
                    height: 18 / 16,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
                Text(
                  DateFormat.MMM(locale).format(date).toUpperCase(),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 10.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 2.h,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // A reason may be in either language.
                Text(
                  detail,
                  textDirection: detail.textDirection,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
          if (onAction != null)
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(0, 36.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                textStyle: textTheme.bodySmall?.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(actionLabel ?? context.l10n.reply),
            ),
        ],
      ),
    );
  }
}
