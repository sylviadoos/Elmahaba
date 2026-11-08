import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// The parent on Settings: initials, [name], [phone] and how many children
/// they have, once known. Tapping it opens their profile.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.name,
    required this.phone,
    required this.childrenCount,
    required this.onTap,
  });

  final String? name;

  /// With its middle hidden, e.g. "0120****154".
  final String? phone;
  final int childrenCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final name = this.name;
    final phone = this.phone;
    final detailStyle = textTheme.bodySmall?.copyWith(
      fontSize: 13.sp,
      color: AppColors.slate,
    );

    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Row(
            spacing: 14.w,
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.blush,
                  shape: BoxShape.circle,
                ),
                child: name == null || name.isEmpty
                    ? AppSvgIcon(
                        AppIcons.user,
                        size: 24.r,
                        color: AppColors.mahabbahRed,
                      )
                    : Text(
                        name.initials,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 19.sp,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mahabbahRed,
                        ),
                      ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3.h,
                  children: [
                    Text(
                      name ?? context.l10n.profile,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Wrap(
                      spacing: 6.w,
                      children: [
                        // No email: the API doesn't send one.
                        if (phone != null)
                          Text(
                            phone,
                            textDirection: TextDirection.ltr,
                            style: detailStyle,
                          ),
                        if (phone != null && childrenCount > 0)
                          Text('·', style: detailStyle),
                        if (childrenCount > 0)
                          Text(
                            context.l10n.childrenCount(childrenCount),
                            style: detailStyle,
                          ),
                      ],
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
