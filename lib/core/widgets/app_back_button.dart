import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/routes/home_on_back.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

enum AppBackButtonStyle {
  /// See-through white circle, for the red headers.
  onRed,

  /// Solid white with a shadow, for use over a photo.
  onPhoto,

  /// Light grey circle, for white pages.
  onLight,
}

/// Round 44 px back button. Goes back, or to [fallbackRoute] when there's
/// nothing to go back to (e.g. the page was opened directly).
///
/// On a parent page it goes Home instead, with the phone's own back
/// button: see [HomeOnBack].
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.style = AppBackButtonStyle.onRed,
    this.fallbackRoute = AppRoutes.explore,
  });

  final AppBackButtonStyle style;
  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    final (background, iconColor) = switch (style) {
      AppBackButtonStyle.onRed => (
        AppColors.white.withValues(alpha: 0.16),
        AppColors.white,
      ),
      AppBackButtonStyle.onPhoto => (AppColors.white, AppColors.ink),
      AppBackButtonStyle.onLight => (AppColors.surface, AppColors.ink),
    };

    final button = IconButton(
      onPressed: () => switch (HomeOnBack.of(context)) {
        true => context.go(AppRoutes.home),
        false when context.canPop() => context.pop(),
        false => context.go(fallbackRoute),
      },
      tooltip: context.l10n.back,
      style: IconButton.styleFrom(
        backgroundColor: background,
        fixedSize: Size.square(44.r),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: AppSvgIcon(
        AppIcons.arrowLeft,
        size: 20.r,
        color: iconColor,
        matchTextDirection: true,
      ),
    );

    if (style != AppBackButtonStyle.onPhoto) return button;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: Offset(0, 6.h),
            blurRadius: 16.r,
          ),
        ],
      ),
      child: button,
    );
  }
}
