import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/double_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';
import 'package:al_mahhaba_school/core/widgets/progress_bar.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_subject_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/grade_band.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_chip.dart';

/// A subject's mark out of its maximum, its bar, its grade (when the result
/// [usesColors]) and the school's assessments. Tapping it shows or hides
/// the parts of the mark ([isOpen]).
class ResultSubjectCard extends StatelessWidget {
  const ResultSubjectCard({
    super.key,
    required this.subject,
    required this.usesColors,
    required this.isOpen,
    required this.onToggle,
  });

  final ResultSubjectEntity subject;
  final bool usesColors;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final share = subject.share;
    final band = GradeBand.of(share);
    final hasParts = subject.components.isNotEmpty;
    final assessments = [
      (l10n.assessmentInitial, subject.initialAssessment),
      (l10n.assessmentFinal, subject.finalAssessment),
      (l10n.assessmentStatus, subject.status),
    ];

    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: hasParts ? onToggle : null,
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8.h,
                children: [
                  Row(
                    spacing: 10.w,
                    children: [
                      Expanded(
                        child: Text(
                          subject.name,
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 15.sp,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _Mark(
                        mark: subject.total,
                        max: subject.maxTotal,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 16.sp,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                        maxSize: 12,
                      ),
                      if (hasParts)
                        // A right chevron turned to point down, or up when
                        // open.
                        AnimatedRotation(
                          turns: isOpen ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Transform.rotate(
                            angle: math.pi / 2,
                            child: AppSvgIcon(
                              AppIcons.chevronRight,
                              size: 18.r,
                              color: AppColors.slate,
                            ),
                          ),
                        ),
                    ],
                  ),
                  ProgressBar(
                    value: share,
                    color: GradeBand.barColor(share, usesColors: usesColors),
                  ),
                  if (usesColors || assessments.any((a) => a.$2 != null))
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
                        if (usesColors)
                          ResultChip(
                            band.label(l10n),
                            color: band.textColor,
                            background: band.background,
                            bold: true,
                          ),
                        for (final (label, value) in assessments)
                          if (value != null) ResultChip('$label: $value'),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (isOpen && hasParts)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10.h,
                children: [
                  const DashedLine(color: AppColors.line, thickness: 1),
                  for (final component in subject.components)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 4.h,
                      children: [
                        Row(
                          spacing: 8.w,
                          children: [
                            Expanded(
                              child: Text(
                                component.name,
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 13.sp,
                                  color: AppColors.slate,
                                ),
                              ),
                            ),
                            _Mark(
                              mark: component.mark,
                              max: component.max,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        ProgressBar(
                          value: component.share,
                          height: 4,
                          color: GradeBand.barColor(
                            component.share,
                            usesColors: usesColors,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// "98.4 / 100", left to right in either language; the max in [maxSize]
/// and grey when given.
class _Mark extends StatelessWidget {
  const _Mark({
    required this.mark,
    required this.max,
    required this.style,
    this.maxSize,
  });

  final double mark;
  final double max;
  final TextStyle? style;
  final double? maxSize;

  @override
  Widget build(BuildContext context) {
    final maxSize = this.maxSize;

    return Text.rich(
      TextSpan(
        text: mark.oneDecimal,
        children: [
          TextSpan(
            text: ' / ${max.oneDecimal}',
            style: maxSize == null
                ? null
                : TextStyle(
                    fontSize: maxSize.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate,
                  ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      style: style,
    );
  }
}
