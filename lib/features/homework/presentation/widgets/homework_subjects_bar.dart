import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_bloc.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_intent.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_state.dart';

/// Under the header, from the [HomeworkBloc]: "All subjects" and a chip
/// per subject the child has homework in, sideways. None with a single
/// subject: nothing to choose.
class HomeworkSubjectsBar extends StatelessWidget {
  const HomeworkSubjectsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeworkBloc, HomeworkState>(
      buildWhen: (previous, current) =>
          previous.subjects != current.subjects ||
          previous.subjectId != current.subjectId,
      builder: (context, state) {
        final subjects = state.subjects;
        if (subjects.length < 2) return const SizedBox.shrink();
        final bloc = context.read<HomeworkBloc>();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(20.w, 2.h, 20.w, 6.h),
          child: Row(
            spacing: 8.w,
            children: [
              _SubjectChip(
                label: context.l10n.allSubjects,
                isSelected: state.subjectId == null,
                onTap: () => bloc.add(const PickHomeworkSubjectIntent(null)),
              ),
              for (final subject in subjects)
                _SubjectChip(
                  label: subject.name,
                  isSelected: state.subjectId == subject.id,
                  onTap: () => bloc.add(PickHomeworkSubjectIntent(subject.id)),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// On the page's light ground: red outline once picked.
class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = StadiumBorder(
      side: BorderSide(
        color: isSelected ? AppColors.mahabbahRed : AppColors.line,
        width: isSelected ? 1.5 : 1,
      ),
    );

    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? AppColors.blushPale : AppColors.white,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.mahabbahRed : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
