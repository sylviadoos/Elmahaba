import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';

/// What a message answers, in a line or two under [label] ("Replying
/// to"), with a bar along its start edge. See-through on the parent's red
/// bubble ([onRed]).
class ChatReplyQuote extends StatelessWidget {
  const ChatReplyQuote({
    super.key,
    required this.label,
    required this.text,
    this.onRed = false,
  });

  final String label;
  final String text;
  final bool onRed;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final accent = onRed ? AppColors.white : AppColors.actionRed;

    // A bar laid over the box: a one-sided border can't have round corners.
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsetsDirectional.fromSTEB(13.w, 6.h, 10.w, 6.h),
            color: onRed
                ? AppColors.white.withValues(alpha: 0.16)
                : AppColors.blush,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    height: 15 / 11,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  // In the language it was written in, on the page's side.
                  textDirection: text.textDirection,
                  textAlign: context.isRtl ? TextAlign.right : TextAlign.left,
                  style: textTheme.bodySmall?.copyWith(
                    color: onRed
                        ? AppColors.white.withValues(alpha: 0.9)
                        : AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: 3.w,
            child: ColoredBox(color: accent),
          ),
        ],
      ),
    );
  }
}
