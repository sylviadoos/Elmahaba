import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// A file's kind, by its [extension], in its color: photos green, PDF red,
/// Word blue (any other grey).
class AttachmentTypeBadge extends StatelessWidget {
  const AttachmentTypeBadge(this.extension, {super.key});

  /// Lower case, e.g. "pdf".
  final String extension;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (extension) {
      'jpg' || 'jpeg' || 'png' => (AppColors.success, AppColors.successBg),
      'pdf' => (AppColors.error, AppColors.errorBg),
      'doc' || 'docx' => (AppColors.info, AppColors.infoBg),
      _ => (AppColors.slate, AppColors.surface),
    };
    final label = switch (extension) {
      'jpeg' => 'JPG',
      '' => '?',
      _ when extension.length > 4 => extension.substring(0, 4).toUpperCase(),
      _ => extension.toUpperCase(),
    };

    return Container(
      width: 40.r,
      height: 40.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        label,
        textDirection: TextDirection.ltr,
        style: context.textTheme.bodySmall?.copyWith(
          fontSize: 10.sp,
          height: 1,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
