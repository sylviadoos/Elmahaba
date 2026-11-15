import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_attachment_kind.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';

/// A file sent in the chat: a PDF's first page on top ([preview]), its
/// type ("PDF") in a badge, its name and size, and a download arrow;
/// opened by tapping it, a spinner in the badge while it downloads. Light
/// on a school card, see-through on the parent's red bubble ([onRed]).
class ChatFileLink extends StatelessWidget {
  const ChatFileLink({
    super.key,
    required this.attachment,
    required this.isDownloading,
    required this.onOpen,
    this.onRed = false,
    this.preview,
  });

  final ChatAttachmentEntity attachment;
  final bool isDownloading;

  /// Over the name, part of the card (a PDF's first page); null for none.
  final Widget? preview;

  /// Null while another file downloads.
  final VoidCallback? onOpen;
  final bool onRed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final foreground = onRed ? AppColors.white : AppColors.mahabbahRed;
    final type = attachment.typeLabel;
    final meta = attachment.isAvailable
        ? '${attachment.size.fileSizeLabel(context)} · ${l10n.tapToOpen}'
        : l10n.checkingFile;

    final radius = BorderRadius.circular(12.r);

    // Not clipped: the ink keeps to the corners by itself, and a clip on
    // every file costs on each frame of a scroll.
    return Material(
      color: onRed
          ? AppColors.white.withValues(alpha: 0.16)
          : AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: attachment.isAvailable && !isDownloading ? onOpen : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ?preview,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: Row(
                spacing: 10.w,
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: onRed
                          ? AppColors.white.withValues(alpha: 0.2)
                          : AppColors.blush,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: isDownloading
                        ? SizedBox.square(
                            dimension: 18.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: foreground,
                            ),
                          )
                        : type.isEmpty
                        ? AppSvgIcon(
                            AppIcons.file,
                            size: 18.r,
                            color: foreground,
                          )
                        : Text(
                            type,
                            maxLines: 1,
                            textDirection: TextDirection.ltr,
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10.sp,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              color: foreground,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2.h,
                      children: [
                        Text(
                          attachment.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // File names read left to right, also on an Arabic
                          // page.
                          textDirection: TextDirection.ltr,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: onRed ? AppColors.white : AppColors.ink,
                          ),
                        ),
                        Text(
                          meta,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            height: 15 / 11,
                            color: onRed
                                ? AppColors.white.withValues(alpha: 0.85)
                                : AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (attachment.isAvailable && !isDownloading)
                    AppSvgIcon(
                      AppIcons.download,
                      size: 18.r,
                      color: foreground,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
