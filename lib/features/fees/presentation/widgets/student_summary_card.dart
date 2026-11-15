import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/equal_height_grid.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_student_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/statement_labels.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/statement_card.dart';

/// Who the statement is for: the student's name, the school, national ID,
/// grade, and today's date.
class StudentSummaryCard extends StatelessWidget {
  const StudentSummaryCard({super.key, required this.student});

  final FeeStudentEntity student;

  /// In the app's language when the school has it.
  String _name(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final preferred = isArabic ? student.nameAr : student.nameEn;
    return preferred.isNotEmpty ? preferred : student.name;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final label = textTheme.bodySmall?.copyWith(
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.slate,
    );
    final name = _name(context);
    final facts = [
      // The API doesn't send it: the app's own name for the school.
      (StatementLabels.school, context.l10n.schoolName),
      (StatementLabels.nationalId, student.nationalId),
      (StatementLabels.grade, student.grade),
      (
        StatementLabels.date,
        DateFormat.yMd(
          Localizations.localeOf(context).toString(),
        ).format(DateTime.now()),
      ),
    ];

    return StatementCard(
      icon: AppIcons.userFilled,
      title: StatementLabels.studentSummary,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16.h,
          children: [
            Row(
              spacing: 14.w,
              children: [
                Container(
                  width: 52.r,
                  height: 52.r,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.actionRed,
                    shape: BoxShape.circle,
                  ),
                  child: AppSvgIcon(
                    AppIcons.userFilled,
                    size: 22.r,
                    color: AppColors.white,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.h,
                    children: [
                      Text(
                        StatementLabels.student,
                        style: label?.copyWith(letterSpacing: 0.5),
                      ),
                      Text(
                        name,
                        textDirection: name.textDirection,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 19.sp,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 14.h),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.hairline)),
              ),
              child: EqualHeightGrid(
                columns: 2,
                spacing: 12.w,
                runSpacing: 14.h,
                children: [
                  for (final (factLabel, value) in facts)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3.h,
                      children: [
                        Text(factLabel, style: label),
                        Text(
                          value.isEmpty ? '—' : value,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
