import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

/// The result's year, when it was published, its title and the student.
class ResultInfoCard extends StatelessWidget {
  const ResultInfoCard({super.key, required this.result});

  final ResultDetailsEntity result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final caption = textTheme.bodySmall?.copyWith(
      fontSize: 12.sp,
      color: AppColors.slate,
    );
    final publishedAt = result.publishedAt;
    final title = result.title.isEmpty ? l10n.result : result.title;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6.h,
        children: [
          Row(
            spacing: 10.w,
            children: [
              if (result.academicYear.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 3.h,
                  ),
                  decoration: const ShapeDecoration(
                    color: AppColors.surface,
                    shape: StadiumBorder(),
                  ),
                  child: Text(
                    result.academicYear,
                    style: caption?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              // At the end, cut short rather than overflow on a narrow
              // phone.
              Expanded(
                child: publishedAt == null
                    ? const SizedBox.shrink()
                    : Text(
                        l10n.publishedOn(
                          DateFormat(
                            'd MMM y',
                            Localizations.localeOf(context).toString(),
                          ).format(publishedAt.toLocal()),
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: caption,
                      ),
              ),
            ],
          ),
          // The school's words: right to left when Arabic, in either language.
          Text(
            title,
            textDirection: title.textDirection,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 17.sp,
              height: 24 / 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (result.studentName.isNotEmpty)
            Text(
              result.studentName,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13.sp,
                color: AppColors.slate,
              ),
            ),
        ],
      ),
    );
  }
}
