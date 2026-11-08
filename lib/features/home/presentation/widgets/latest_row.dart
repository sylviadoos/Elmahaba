import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';

/// One of the latest in a `LatestCard`: a red dot when the parent hasn't
/// seen it, [title] with [trailing] (e.g. its date) at the end, then
/// [subtitle] with [subtitleEnd] (e.g. a badge) at the end.
class LatestRow extends StatelessWidget {
  const LatestRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.subtitleEnd,
    this.unread = false,
    this.onTap,
  });

  /// As the school wrote it, in either language.
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? subtitleEnd;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    // Written in its own direction, lined up with the page's start.
    final align = context.isRtl ? TextAlign.right : TextAlign.left;
    final subtitle = this.subtitle;
    final hasSubtitle = subtitle != null && subtitle.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 3.h,
          children: [
            Row(
              spacing: 8.w,
              children: [
                if (unread)
                  Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: const BoxDecoration(
                      color: AppColors.actionRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: title.textDirection,
                    textAlign: align,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            if (hasSubtitle || subtitleEnd != null)
              Row(
                spacing: 8.w,
                children: [
                  Expanded(
                    child: hasSubtitle
                        ? Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: subtitle.textDirection,
                            textAlign: align,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.slate,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  ?subtitleEnd,
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// A [LatestRow]'s date, e.g. "Today" or "5 Nov".
class LatestRowDate extends StatelessWidget {
  const LatestRowDate(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.textTheme.bodySmall?.copyWith(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.mist,
      ),
    );
  }
}
