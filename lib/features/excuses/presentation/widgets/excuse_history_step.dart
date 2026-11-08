import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_history_entity.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/extensions/excuse_labels.dart';

/// A step in an excuse's history: a dot on the line (none under the
/// [last]), what happened, who did it and when, and what was said.
class ExcuseHistoryStep extends StatelessWidget {
  const ExcuseHistoryStep({super.key, required this.step, this.last = false});

  final ExcuseHistoryEntity step;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final text = step.text;
    final at = step.at;
    final meta = [
      step.byLabel(context),
      if (at != null) at.dateTimeLabel(context),
    ].where((part) => part.isNotEmpty).join(' · ');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12.w,
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 4.h),
                width: 10.r,
                height: 10.r,
                decoration: const BoxDecoration(
                  color: AppColors.mahabbahRed,
                  shape: BoxShape.circle,
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: AppColors.line,
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2.h,
                children: [
                  Text(
                    step.actionLabel(context),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (meta.isNotEmpty)
                    Text(
                      meta,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.slate,
                      ),
                    ),
                  if (text != null)
                    Text(
                      text,
                      textDirection: text.textDirection,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.ink,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
