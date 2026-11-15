import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// The photo and PDF viewers' top bar: close, the file's name and
/// which photo of how many ([position]), and open in another app (to save
/// or share it).
class ChatViewerBar extends StatelessWidget {
  const ChatViewerBar({
    super.key,
    required this.title,
    this.position,
    required this.onClose,
    required this.onOpenElsewhere,
  });

  final String title;

  /// "2 / 3"; null for a photo alone.
  final String? position;
  final VoidCallback onClose;
  final VoidCallback onOpenElsewhere;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final position = this.position;

    return ColoredBox(
      color: AppColors.darkBackground.withValues(alpha: 0.6),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          child: Row(
            spacing: 4.w,
            children: [
              IconButton(
                onPressed: onClose,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: AppSvgIcon(
                  AppIcons.close,
                  size: 22.r,
                  color: AppColors.white,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // File names read left to right, also on an Arabic
                      // page.
                      textDirection: TextDirection.ltr,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    if (position != null)
                      Text(
                        position,
                        // "1 / 3", not flipped to "3 / 1" on an Arabic page.
                        textDirection: TextDirection.ltr,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.white.withValues(alpha: 0.75),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onOpenElsewhere,
                tooltip: context.l10n.openInAnotherApp,
                icon: AppSvgIcon(
                  AppIcons.download,
                  size: 22.r,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
