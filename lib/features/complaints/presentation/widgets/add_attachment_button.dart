import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';

/// "Add file" in a dashed red outline, with a [subtitle] under it (e.g.
/// how many more fit); greyed out when [onPressed] is null.
class AddAttachmentButton extends StatelessWidget {
  const AddAttachmentButton({
    super.key,
    required this.onPressed,
    this.subtitle,
  });

  final VoidCallback? onPressed;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.r);
    final textTheme = context.textTheme;
    final subtitle = this.subtitle;

    return Opacity(
      opacity: onPressed == null ? 0.45 : 1,
      child: DashedBorder(
        radius: 14.r,
        // See-through, so the outline behind it shows.
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 48.h),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: subtitle == null ? 0 : 8.h,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 2.h,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8.w,
                      children: [
                        AppSvgIcon(
                          AppIcons.paperclip,
                          size: 18.r,
                          color: AppColors.actionRed,
                        ),
                        Flexible(
                          child: Text(
                            context.l10n.addFile,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.actionRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          height: 16 / 12,
                          color: AppColors.slate,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
