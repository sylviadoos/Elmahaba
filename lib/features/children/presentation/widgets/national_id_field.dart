import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';

/// The child's national ID with a "7 / 14" counter, and the Add button,
/// enabled once all 14 digits are in. Rebuild it on [onChanged] so both
/// follow [controller].
class NationalIdField extends StatelessWidget {
  const NationalIdField({
    super.key,
    required this.controller,
    required this.isLinking,
    required this.onChanged,
    required this.onAdd,
    this.errorText,
  });

  static const int length = 14;

  final TextEditingController controller;

  /// Shows a spinner on the Add button.
  final bool isLinking;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;

  /// The server's error for the ID.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final typed = controller.text.length;

    return AppTextField(
      controller: controller,
      label: l10n.childNationalId,
      labelTrailing: Text(
        '$typed / $length',
        style: textTheme.bodySmall?.copyWith(color: AppColors.slate),
      ),
      hint: l10n.nationalIdDigitsHint,
      prefixIcon: AppIcons.idCard,
      keyboardType: TextInputType.number,
      letterSpacing: 0.5,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      onChanged: onChanged,
      errorText: errorText,
      helperText: l10n.nationalIdMatchNote,
      action: ElevatedButton(
        onPressed: typed == length && !isLinking ? onAdd : null,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0, 54.h),
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15.sp),
        ),
        child: isLinking
            ? SizedBox.square(
                dimension: 20.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l10n.add),
      ),
    );
  }
}
