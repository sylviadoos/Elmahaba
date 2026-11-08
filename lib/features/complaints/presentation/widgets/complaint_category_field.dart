import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_select_field.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_category_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';

/// "Category": the school's complaint categories to pick from, a
/// placeholder while they load, or why they didn't with "Try again".
class ComplaintCategoryField extends StatelessWidget {
  const ComplaintCategoryField({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
    required this.onRetry,
    this.errorText,
  });

  final BaseState<List<ComplaintCategoryEntity>> categories;

  /// The picked category's id.
  final int? selected;
  final ValueChanged<int> onSelected;
  final VoidCallback onRetry;
  final String? errorText;

  static const double _height = 52;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    Widget labelled(Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8.h,
      children: [
        Text(
          l10n.complaintCategory,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        child,
      ],
    );

    final loading = labelled(
      SkeletonPulse(
        child: Container(
          height: _height.h,
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );

    return categories.when(
      initial: () => loading,
      loading: () => loading,
      error: (exception) => labelled(
        Row(
          spacing: 8.w,
          children: [
            Expanded(
              child: Text(
                exception.localizedMessage(context),
                style: textTheme.bodySmall?.copyWith(color: AppColors.slate),
              ),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ],
        ),
      ),
      success: (categories) => AppSelectField<ComplaintCategoryEntity>(
        label: l10n.complaintCategory,
        labelWeight: FontWeight.w600,
        hint: l10n.chooseCategory,
        height: _height,
        options: categories,
        value: categories
            .where((category) => category.id == selected)
            .firstOrNull,
        optionLabel: (category) => category.name(context),
        onChanged: (category) => onSelected(category.id),
        errorText: errorText,
      ),
    );
  }
}
