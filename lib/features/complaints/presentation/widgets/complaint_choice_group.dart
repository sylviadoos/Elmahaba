import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_choice_chip.dart';

/// A [label] over [options] (value, text) as chips, and a [hint] below; one
/// is picked at a time, and none while [selected] matches none of them.
class ComplaintChoiceGroup<T> extends StatelessWidget {
  const ComplaintChoiceGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.hint,
  });

  final String label;
  final List<(T, String)> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final hint = this.hint;

    return Semantics(
      container: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8.h,
        children: [
          ExcludeSemantics(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final (value, text) in options)
                ComplaintChoiceChip(
                  label: text,
                  isSelected: value == selected,
                  onTap: () => onSelected(value),
                ),
            ],
          ),
          if (hint != null)
            Text(
              hint,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                height: 16 / 12,
                color: AppColors.slate,
              ),
            ),
        ],
      ),
    );
  }
}
