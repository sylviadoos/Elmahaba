import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/child_display.dart';

/// One of the parent's children: initial, name and grade. Tapping it opens
/// their details.
class ProfileChildRow extends StatelessWidget {
  const ProfileChildRow(this.child, {super.key});

  final ChildEntity child;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final name = child.displayName(context);

    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.childDetailsOf(child.studentId),
          extra: child,
        ),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            spacing: 12.w,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.blush,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  name.characters.first,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 17.sp,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mahabbahRed,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2.h,
                  children: [
                    Text(
                      name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 15.sp,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      child.summary(context),
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              AppSvgIcon(
                AppIcons.chevronRight,
                size: 18.r,
                color: AppColors.mist,
                matchTextDirection: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
