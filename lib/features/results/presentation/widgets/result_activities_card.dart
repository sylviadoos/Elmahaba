import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/section_title.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_activity_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_chip.dart';

/// The activities and their status, in green when passed.
class ResultActivitiesCard extends StatelessWidget {
  const ResultActivitiesCard({super.key, required this.activities});

  final List<ResultActivityEntity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10.h,
      children: [
        SectionTitle(context.l10n.activities),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              for (final (index, activity) in activities.indexed)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: index == 0
                      ? null
                      : const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.hairline),
                          ),
                        ),
                  child: Row(
                    spacing: 12.w,
                    children: [
                      Expanded(
                        child: Text(
                          activity.name,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ResultChip(
                        activity.status ?? '—',
                        color: activity.passed
                            ? AppColors.success
                            : AppColors.slate,
                        background: activity.passed
                            ? AppColors.successBg
                            : AppColors.surface,
                        bold: true,
                        large: true,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
