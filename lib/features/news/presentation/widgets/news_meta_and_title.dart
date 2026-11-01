import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';

/// The text part of a news card: a red meta line, the title, and an
/// optional excerpt.
class NewsMetaAndTitle extends StatelessWidget {
  const NewsMetaAndTitle({
    super.key,
    required this.meta,
    required this.title,
    this.excerpt,
    required this.titleSize,
    required this.titleHeight,
    this.titleMaxLines,
  });

  /// Red line above the title, e.g. the date.
  final String? meta;
  final String title;
  final String? excerpt;
  final double titleSize;
  final double titleHeight;

  /// Cuts a long title with "…"; null shows it all.
  final int? titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final meta = this.meta;
    final excerpt = this.excerpt;

    // News text comes from the API in its own language (English for now).
    // Lay it out in that language's direction so punctuation such as a
    // trailing "..." stays at its end, but keep it on the page's start side.
    final textAlign = Directionality.of(context) == TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6.h,
      children: [
        if (meta != null)
          Text(
            meta,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.mahabbahRed,
            ),
          ),
        Text(
          title,
          textDirection: title.textDirection,
          textAlign: textAlign,
          maxLines: titleMaxLines,
          overflow: titleMaxLines == null ? null : TextOverflow.ellipsis,
          style: textTheme.bodyLarge?.copyWith(
            fontSize: titleSize.sp,
            height: titleHeight / titleSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (excerpt != null && excerpt.isNotEmpty)
          Text(
            excerpt,
            textDirection: excerpt.textDirection,
            textAlign: textAlign,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              height: 20 / 14,
              color: AppColors.slate,
            ),
          ),
      ],
    );
  }
}
