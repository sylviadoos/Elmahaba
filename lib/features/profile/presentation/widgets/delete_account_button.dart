import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// "Delete my account", quieter than Log out; a spinner while deleting.
class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.slate,
          minimumSize: Size(0, 44.h),
          textStyle: context.textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: 18.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(context.l10n.deleteMyAccount),
      ),
    );
  }
}
