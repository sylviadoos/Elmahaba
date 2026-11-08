import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';

/// What the calendar's colors mean.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = 12.r;
    final radius = BorderRadius.circular(4.r);

    Widget swatch(Color color) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: radius),
    );

    final items = [
      (swatch(AppColors.mahabbahRed), l10n.absent),
      (
        DashedBorder(
          radius: 4.r,
          child: SizedBox.square(dimension: size),
        ),
        l10n.late,
      ),
      (swatch(AppColors.infoBg), l10n.excusedOrMedical),
      (swatch(AppColors.gold), l10n.officialHoliday),
      (swatch(AppColors.surface), l10n.friSatOff),
    ];

    return Wrap(
      spacing: 12.w,
      runSpacing: 8.h,
      children: [
        for (final (marker, label) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6.w,
            children: [
              marker,
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
