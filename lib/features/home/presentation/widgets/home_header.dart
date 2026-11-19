import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/parent_context.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_picker.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaints_button.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/settings_button.dart';

/// The parent's name (their profile), Settings and complaints, and the
/// child picker.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.children,
    required this.selectedChild,
    required this.onChildSelected,
  });

  /// The parent's children; the picker shows once there are some.
  final List<ChildEntity> children;
  final int selectedChild;
  final ValueChanged<int> onChildSelected;

  @override
  Widget build(BuildContext context) {
    return RedHeader(
      horizontalPadding: 16,
      bottomPadding: 36,
      watermarkTop: 26,
      watermarkSize: const Size(250, 178),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14.h,
        children: [
          Row(
            spacing: 8.w,
            children: [
              const Expanded(child: _ProfileLink()),
              const SettingsButton(),
              const ComplaintsButton(),
            ],
          ),
          if (children.isNotEmpty)
            ChildPicker(
              children: children,
              selected: selectedChild,
              onSelected: onChildSelected,
            ),
        ],
      ),
    );
  }
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    // Null until it loads, or when signed in before it was kept.
    final parent = context.watchParent();

    return InkWell(
      onTap: () => context.push(AppRoutes.settings),
      borderRadius: BorderRadius.circular(22.r),
      child: Row(
        spacing: 12.w,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: parent == null
                ? AppSvgIcon(
                    AppIcons.user,
                    size: 20.r,
                    color: AppColors.mahabbahRed,
                  )
                : Text(
                    parent.initials,
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 15.sp,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mahabbahRed,
                    ),
                  ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (parent != null)
                  Row(
                    spacing: 4.w,
                    children: [
                      Flexible(
                        child: Text(
                          parent.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleLarge?.copyWith(
                            height: 22 / 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      AppSvgIcon(
                        AppIcons.chevronRight,
                        size: 16.r,
                        color: AppColors.white,
                        matchTextDirection: true,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
