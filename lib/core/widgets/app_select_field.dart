import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// A dropdown in the style of `AppTextField`: tapping the box opens a
/// bottom sheet of [options], and the chosen one shows in the box.
class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    this.label,
    this.labelTrailing,
    required this.hint,
    required this.options,
    required this.value,
    required this.optionLabel,
    required this.onChanged,
    this.prefixIcon,
    this.errorText,
    this.height = 54,
    this.labelGap = 8,
  });

  final String? label;

  /// Shown at the end of the label row, e.g. "Optional".
  final Widget? labelTrailing;

  /// Shown in the box while nothing is chosen.
  final String hint;
  final List<T> options;
  final T? value;
  final String Function(T option) optionLabel;
  final ValueChanged<T> onChanged;

  /// Icon asset shown at the start of the box.
  final String? prefixIcon;

  /// Shown below the box in red; also turns the border red.
  final String? errorText;

  /// Design values, in pixels.
  final double height;
  final double labelGap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final value = this.value;
    final label = this.label;
    final errorText = this.errorText;
    final inputStyle = textTheme.bodyLarge?.copyWith(height: 1.25);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: labelGap.h,
      children: [
        if (label != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ?labelTrailing,
            ],
          ),
        Material(
          color: AppColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: BorderSide(
              color: errorText != null ? AppColors.error : AppColors.line,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () => _pick(context),
            child: SizedBox(
              height: height.h,
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: (prefixIcon == null ? 16 : 14).w,
                  end: 14.w,
                ),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      AppSvgIcon(
                        prefixIcon!,
                        size: 20.r,
                        color: AppColors.slate,
                      ),
                      SizedBox(width: 10.w),
                    ],
                    Expanded(
                      child: Text(
                        value == null ? hint : optionLabel(value),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: value == null
                            ? inputStyle?.copyWith(color: AppColors.placeholder)
                            : inputStyle,
                      ),
                    ),
                    // Chevron pointing down.
                    RotatedBox(
                      quarterTurns: 1,
                      child: AppSvgIcon(
                        AppIcons.chevronRight,
                        size: 18.r,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (errorText != null)
          Text(
            errorText,
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => _OptionsSheet<T>(
        title: label ?? hint,
        options: options,
        selected: value,
        optionLabel: optionLabel,
      ),
    );
    if (picked != null) onChanged(picked);
  }
}

class _OptionsSheet<T> extends StatelessWidget {
  const _OptionsSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.optionLabel,
  });

  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T option) optionLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
            child: Text(title, style: textTheme.titleLarge),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: 12.h),
              children: [
                for (final option in options)
                  _OptionTile(
                    label: optionLabel(option),
                    isSelected: option == selected,
                    onTap: () => Navigator.pop(context, option),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      child: Material(
        color: isSelected ? AppColors.blush : AppColors.white,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? AppColors.mahabbahRed : AppColors.ink,
                    ),
                  ),
                ),
                if (isSelected)
                  AppSvgIcon(
                    AppIcons.check,
                    size: 20.r,
                    color: AppColors.mahabbahRed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
