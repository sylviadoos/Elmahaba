import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';

/// A document sent with an excuse: its name and size, opened by tapping
/// it; a spinner while it downloads.
class ExcuseDocumentLink extends StatelessWidget {
  const ExcuseDocumentLink({
    super.key,
    required this.document,
    required this.isDownloading,
    required this.onOpen,
  });

  final ExcuseDocumentEntity document;
  final bool isDownloading;

  /// Null while another file downloads.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: document.isAvailable && !isDownloading ? onOpen : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            spacing: 10.w,
            children: [
              if (isDownloading)
                SizedBox.square(
                  dimension: 18.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.mahabbahRed,
                  ),
                )
              else
                AppSvgIcon(
                  AppIcons.file,
                  size: 18.r,
                  color: AppColors.mahabbahRed,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // File names read left to right, also on an Arabic
                      // page.
                      textDirection: TextDirection.ltr,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      document.isAvailable
                          ? '${document.size.fileSizeLabel(context)} · '
                                '${context.l10n.tapToOpen}'
                          : context.l10n.checkingFile,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
                        height: 15 / 11,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
