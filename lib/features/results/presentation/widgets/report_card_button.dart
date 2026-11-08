import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// "Download report card (PDF)", outlined in red.
class ReportCardButton extends StatelessWidget {
  const ReportCardButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      // TODO: download the report card PDF — the API doesn't link one yet.
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.actionRed,
        minimumSize: Size.fromHeight(50.h),
        side: const BorderSide(color: AppColors.actionRed, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        textStyle: context.textTheme.labelLarge?.copyWith(fontSize: 15.sp),
      ),
      icon: AppSvgIcon(AppIcons.download, size: 18.r),
      label: Text(context.l10n.downloadReportCard),
    );
  }
}
