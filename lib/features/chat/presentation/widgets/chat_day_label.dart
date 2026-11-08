import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// Grey pill above a day's items: "Today", "Yesterday", "Monday 2 Nov".
class ChatDayLabel extends StatelessWidget {
  const ChatDayLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: const ShapeDecoration(
          color: AppColors.line,
          shape: StadiumBorder(),
        ),
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.slate,
          ),
        ),
      ),
    );
  }
}
