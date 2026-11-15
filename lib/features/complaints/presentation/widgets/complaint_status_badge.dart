import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_status.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';

/// "Submitted", "Under review"… in its colors; [onRed] makes a larger,
/// white one for the red header.
class ComplaintStatusBadge extends StatelessWidget {
  const ComplaintStatusBadge(this.status, {super.key, this.onRed = false});

  final ComplaintStatus status;
  final bool onRed;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = status.colors;

    return Container(
      padding: onRed
          ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h)
          : EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: ShapeDecoration(
        color: onRed ? AppColors.white : background,
        shape: const StadiumBorder(),
      ),
      child: Text(
        status.label(context),
        maxLines: 1,
        style: context.textTheme.bodySmall?.copyWith(
          fontSize: 12.sp,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
