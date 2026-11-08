import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// "2 children" pill next to the "Your children" title.
class ChildrenCountBadge extends StatelessWidget {
  const ChildrenCountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: const ShapeDecoration(
        color: AppColors.blush,
        shape: StadiumBorder(),
      ),
      child: Text(
        context.l10n.childrenCount(count),
        style: context.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.mahabbahRed,
        ),
      ),
    );
  }
}
