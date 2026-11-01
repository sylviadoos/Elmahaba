import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// Section heading ("Latest news", "Follow us"…) with an optional
/// [trailing] widget on the other side, e.g. a "See all" link.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      text,
      style: context.textTheme.titleLarge?.copyWith(
        fontSize: 17.sp,
        height: 1.25,
      ),
    );
    if (trailing == null) return title;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: title),
        trailing!,
      ],
    );
  }
}
