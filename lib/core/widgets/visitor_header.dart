import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';

/// Header of a visitor page: back button, [title] and [subtitle].
class VisitorHeader extends StatelessWidget {
  const VisitorHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return RedHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6.h,
        children: [
          Row(
            spacing: 10.w,
            children: [
              const AppBackButton(),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 15.sp,
              height: 1.3,
              color: AppColors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}
