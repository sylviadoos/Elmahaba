import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';

/// Red header: back, "Profile", and the parent's initials, [name] and
/// [phone] — once known.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.name, required this.phone});

  final String? name;

  /// With its middle hidden, e.g. "0120****154".
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final name = this.name;
    final phone = this.phone;

    return RedHeader(
      horizontalPadding: 16,
      bottomPadding: 44,
      watermarkTop: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16.h,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppBackButton(fallbackRoute: AppRoutes.settings),
              Text(
                l10n.profile,
                style: textTheme.titleLarge?.copyWith(color: AppColors.white),
              ),
              // As wide as back, so the title stays centred.
              SizedBox(width: 44.r),
            ],
          ),
          Row(
            spacing: 14.w,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: name == null || name.isEmpty
                    ? AppSvgIcon(
                        AppIcons.user,
                        size: 28.r,
                        color: AppColors.mahabbahRed,
                      )
                    : Text(
                        name.initials,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 22.sp,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mahabbahRed,
                        ),
                      ),
              ),
              if (name != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.h,
                    children: [
                      Text(
                        name,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 20.sp,
                          height: 1.25,
                          color: AppColors.white,
                        ),
                      ),
                      // No email: the API doesn't send one.
                      if (phone != null)
                        Text(
                          phone,
                          textDirection: TextDirection.ltr,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.88),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
