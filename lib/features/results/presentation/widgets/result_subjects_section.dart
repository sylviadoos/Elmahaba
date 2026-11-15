import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/section_title.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_subject_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_subject_card.dart';

/// A titled group of subjects — counted in the final result, not counted,
/// or the high level — with a line saying which. [openIndex] is the
/// subject shown open, if it's in this group.
class ResultSubjectsSection extends StatelessWidget {
  const ResultSubjectsSection({
    super.key,
    required this.title,
    required this.note,
    required this.subjects,
    required this.usesColors,
    required this.openIndex,
    required this.onToggle,
  });

  final String title;
  final String note;
  final List<ResultSubjectEntity> subjects;
  final bool usesColors;
  final int? openIndex;

  /// The subject at this index was tapped.
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10.h,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2.h,
          children: [
            SectionTitle(title),
            Text(
              note,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                color: AppColors.slate,
              ),
            ),
          ],
        ),
        for (final (index, subject) in subjects.indexed)
          ResultSubjectCard(
            subject: subject,
            usesColors: usesColors,
            isOpen: index == openIndex,
            onToggle: () => onToggle(index),
          ),
      ],
    );
  }
}
