import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';

/// "Add a child" (or [label]), in a dashed red outline; opens Add children,
/// unless [onPressed] does something else.
class AddChildButton extends StatelessWidget {
  const AddChildButton({super.key, this.label, this.onPressed});

  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = 14.r;

    return DashedBorder(
      radius: radius,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed ?? () => context.push(AppRoutes.addChildren),
          child: SizedBox(
            height: 48.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8.w,
              children: [
                AppSvgIcon(
                  AppIcons.plus,
                  size: 16.r,
                  color: AppColors.actionRed,
                ),
                Text(
                  label ?? context.l10n.addAChild,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.actionRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
