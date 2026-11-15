import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';

/// Where the files come from: the photo gallery, or the phone's files.
enum AttachmentSource { photos, documents }

/// Asks where to attach from.
///
/// `await AttachmentSourceSheet.show(context)` is null when dismissed.
class AttachmentSourceSheet extends StatelessWidget {
  const AttachmentSourceSheet({super.key});

  static Future<AttachmentSource?> show(BuildContext context) =>
      showModalBottomSheet<AttachmentSource>(
        context: context,
        backgroundColor: AppColors.white,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        ),
        builder: (_) => const AttachmentSourceSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget option(AttachmentSource source, String icon, String label) =>
        ListTile(
          onTap: () => Navigator.of(context).pop(source),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
          leading: IconBox(icon, size: 40.r, iconSize: 20.r, circle: true),
          title: Text(
            label,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            option(AttachmentSource.photos, AppIcons.photo, l10n.attachPhoto),
            option(
              AttachmentSource.documents,
              AppIcons.fileReport,
              l10n.attachDocument,
            ),
          ],
        ),
      ),
    );
  }
}
