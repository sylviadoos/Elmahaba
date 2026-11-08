import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/presentation/extensions/homework_labels.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_due_badge.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_file_link.dart';

/// One homework: its subject ("New" while unread), title and what to do,
/// when it's due and when it was given, and its files.
class HomeworkCard extends StatelessWidget {
  const HomeworkCard(this.homework, {super.key});

  final HomeworkEntity homework;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final direction = homework.textDirection;
    final align = context.isRtl ? TextAlign.right : TextAlign.left;
    final given = homework.issueDate?.homeworkDayLabel(context);
    final note = textTheme.bodySmall?.copyWith(
      fontSize: 12.sp,
      height: 16 / 12,
      color: AppColors.slate,
    );

    // Flat: the border sets it apart, no shadow to paint as it scrolls.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.h,
          children: [
            Row(
              spacing: 8.w,
              children: [
                // The subject at the start, "New" at the end.
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _SubjectChip(homework.subject),
                  ),
                ),
                if (!homework.isRead) _NewChip(l10n.homeworkNew),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4.h,
              children: [
                Text(
                  homework.title,
                  textDirection: direction,
                  textAlign: align,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 16.sp,
                    height: 22 / 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (homework.description.isNotEmpty)
                  Text(
                    homework.description,
                    textDirection: direction,
                    textAlign: align,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate,
                    ),
                  ),
              ],
            ),
            Wrap(
              spacing: 10.w,
              runSpacing: 6.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                HomeworkDueBadge(
                  status: homework.dueStatus,
                  label: homework.dueLabel(context),
                ),
                if (given != null)
                  Text(
                    [
                      l10n.homeworkGiven(given),
                      if (homework.isEdited) l10n.edited,
                    ].join(' · '),
                    style: note,
                  ),
              ],
            ),
            for (final attachment in homework.attachments)
              HomeworkFileLink(attachment),
          ],
        ),
      ),
    );
  }
}

/// The subject, with a book, in the brand's soft red.
class _SubjectChip extends StatelessWidget {
  const _SubjectChip(this.subject);

  final String subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: const ShapeDecoration(
        color: AppColors.blush,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6.w,
        children: [
          AppSvgIcon(AppIcons.book, size: 14.r, color: AppColors.mahabbahRed),
          Flexible(
            child: Text(
              subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                height: 16 / 12,
                fontWeight: FontWeight.w700,
                color: AppColors.mahabbahRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "New", while the parent hasn't seen it.
class _NewChip extends StatelessWidget {
  const _NewChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: const ShapeDecoration(
        color: AppColors.gold,
        shape: StadiumBorder(),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          fontSize: 11.sp,
          height: 15 / 11,
          fontWeight: FontWeight.w700,
          color: AppColors.goldText,
        ),
      ),
    );
  }
}
