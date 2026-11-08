import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';

/// The school's answer to an excuse, in a box of its color: an optional
/// [title] ("Why it was rejected") over [text].
class ExcuseNotice extends StatelessWidget {
  const ExcuseNotice({
    super.key,
    this.title,
    required this.text,
    required this.foreground,
    required this.background,
  });

  final String? title;
  final String text;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final title = this.title;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4.h,
        children: [
          if (title != null)
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          // The school's words: right to left when Arabic.
          Text(
            text,
            textDirection: text.textDirection,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: title == null ? FontWeight.w600 : null,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
