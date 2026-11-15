import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_thumbnail.dart';

/// A file picked to send (a photo, small), its size, and a button to take
/// it off.
class AttachmentTile extends StatelessWidget {
  const AttachmentTile({
    super.key,
    required this.file,
    required this.onRemove,
    this.onPreview,
  });

  final PickedAttachment file;

  /// Null while it can't be taken off (it's being sent).
  final VoidCallback? onRemove;

  /// Shows a photo bigger, from its thumbnail; null where that isn't
  /// offered.
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(12.w, 10.h, 6.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        spacing: 10.w,
        children: [
          if (file.isImage)
            AttachmentThumbnail(file, onTap: onPreview)
          else
            IconBox(AppIcons.file, size: 36.r, iconSize: 18.r, radius: 10.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // File names read left to right, also on an Arabic page.
                  textDirection: TextDirection.ltr,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  file.size.fileSizeLabel(context),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    height: 16 / 12,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
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
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }
}
