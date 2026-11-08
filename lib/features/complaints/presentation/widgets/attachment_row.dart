import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_labels.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_type_badge.dart';

/// A file picked to send: its kind, name and size, and "Remove". While it
/// uploads, how far it got; one that won't be sent is red, with why.
class AttachmentRow extends StatelessWidget {
  const AttachmentRow({
    super.key,
    required this.file,
    required this.bytesLeft,
    this.progress,
    required this.onRemove,
  });

  final PickedAttachment file;

  /// What's still free of the total, for why a file doesn't fit.
  final int bytesLeft;

  /// 0 to 1 while it's being sent.
  final double? progress;

  /// Null while it can't be taken off (it's being sent).
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final problem = file.problemLabel(context, bytesLeft: bytesLeft);
    final progress = this.progress;
    final failed = problem != null;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(10.w, 10.h, 4.w, 10.h),
      decoration: BoxDecoration(
        color: failed ? AppColors.errorBg : AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: failed ? AppColors.errorBorder : AppColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8.h,
        children: [
          Row(
            spacing: 10.w,
            children: [
              AttachmentTypeBadge(file.extension),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2.h,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // File names read left to right, also on an Arabic
                      // page.
                      textDirection: TextDirection.ltr,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      problem ??
                          (progress == null
                              ? file.size.fileSizeLabel(context)
                              : context.l10n.attachmentUploading(
                                  (progress * 100).round(),
                                )),
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        height: 16 / 12,
                        fontWeight: failed ? FontWeight.w600 : null,
                        color: failed ? AppColors.error : AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              // None while it's going.
              if (progress != null)
                SizedBox(width: 8.w)
              else
                IconButton(
                  onPressed: onRemove,
                  tooltip: context.l10n.removeAttachment(file.name),
                  style: IconButton.styleFrom(
                    fixedSize: Size.square(40.r),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: AppSvgIcon(
                    AppIcons.close,
                    size: 18.r,
                    color: failed ? AppColors.error : AppColors.slate,
                  ),
                ),
            ],
          ),
          if (progress != null)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 6.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4.h,
                  color: AppColors.actionRed,
                  backgroundColor: AppColors.rose,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
