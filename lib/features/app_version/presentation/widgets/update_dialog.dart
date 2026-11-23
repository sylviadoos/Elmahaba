import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/app_version/domain/entities/app_version_entity.dart';

/// The card asking for an update: what the school says (or the app's own
/// words), the new version, "Update", and — when it isn't forced — "Later".
/// Flat, white, centered by whoever shows it.
class UpdateDialog extends StatelessWidget {
  const UpdateDialog({
    super.key,
    required this.update,
    required this.onUpdate,
    this.onLater,
  });

  final AppVersionEntity update;

  /// Opens the store page.
  final VoidCallback onUpdate;

  /// "Later"; null for a forced update, which has none.
  final VoidCallback? onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final forced = update.forceUpdate;
    final onLater = this.onLater;
    final message = update.message.isNotEmpty
        ? update.message
        : forced
        ? l10n.updateRequiredMessage
        : l10n.updateAvailableMessage;

    return Container(
      constraints: BoxConstraints(maxWidth: 360.w),
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64.r,
              height: 64.r,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.blush,
                shape: BoxShape.circle,
              ),
              child: AppSvgIcon(
                AppIcons.download,
                size: 28.r,
                color: AppColors.mahabbahRed,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            forced ? l10n.updateRequired : l10n.updateAvailable,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 20.sp,
              height: 26 / 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            message,
            textAlign: TextAlign.center,
            textDirection: message.textDirection,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
          ),
          if (update.latestVersion.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              l10n.newVersionNumber(update.latestVersion.ltrIsolated),
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.mahabbahRed,
              ),
            ),
          ],
          SizedBox(height: 22.h),
          AppButton(
            label: l10n.updateNow,
            icon: AppSvgIcon(AppIcons.download, size: 20.r),
            onPressed: onUpdate,
          ),
          if (onLater != null) ...[
            SizedBox(height: 6.h),
            TextButton(
              onPressed: onLater,
              child: Text(
                l10n.updateLater,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
