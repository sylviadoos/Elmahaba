import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_status_badge.dart';

/// One complaint: its reference and status, its category and who it's
/// about, and when it was sent and last updated. Tapping it opens it
/// ([onTap]).
class ComplaintCard extends StatelessWidget {
  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  final ComplaintEntity complaint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.r);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            offset: Offset(0, 4.h),
            blurRadius: 14.r,
          ),
        ],
      ),
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              spacing: 12.w,
              children: [
                Expanded(child: _content(context)),
                AppSvgIcon(
                  AppIcons.chevronRight,
                  size: 18.r,
                  color: AppColors.mist,
                  matchTextDirection: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final textTheme = context.textTheme;
    final dates = complaint.datesLabel(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6.h,
      children: [
        Row(
          spacing: 8.w,
          children: [
            Expanded(
              child: Text(
                complaint.referenceLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 14.sp,
                  height: 18 / 14,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            ComplaintStatusBadge(complaint.status),
          ],
        ),
        Text(
          '${complaint.categoryName(context)} · ${complaint.aboutLabel(context)}',
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (dates.isNotEmpty)
          Text(
            dates,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
              height: 16 / 12,
              color: AppColors.slate,
            ),
          ),
      ],
    );
  }
}
