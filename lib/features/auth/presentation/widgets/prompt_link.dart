import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// Centered grey prompt followed by a red link, e.g.
/// "New parent? Create an account".
class PromptLink extends StatelessWidget {
  const PromptLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
    this.fontSize = 15,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyMedium?.copyWith(
      fontSize: fontSize.sp,
      color: AppColors.slate,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('$prompt ', style: style),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.actionRed,
            minimumSize: Size(0, 44.h),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: style?.copyWith(fontWeight: FontWeight.w600),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}
