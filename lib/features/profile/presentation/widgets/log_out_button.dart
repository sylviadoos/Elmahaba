import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/confirm_dialog.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';

/// "Log out", on a pale red bar; asks first.
class LogOutButton extends StatelessWidget {
  const LogOutButton({super.key});

  Future<void> _logOut(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.logOutTitle,
      message: l10n.logOutMessage,
      confirmLabel: l10n.logout,
    );
    if (confirmed && context.mounted) await context.logOut();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blush,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _logOut(context),
        child: SizedBox(
          height: 52.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8.w,
            children: [
              AppSvgIcon(
                AppIcons.logOut,
                size: 18.r,
                color: AppColors.mahabbahRed,
                matchTextDirection: true,
              ),
              Text(
                context.l10n.logout,
                style: context.textTheme.labelLarge?.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.mahabbahRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
