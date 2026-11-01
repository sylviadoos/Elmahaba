import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/onboarding/presentation/widgets/onboarding_illustration.dart';

/// Pink top area of an onboarding slide: the top bar, the Lottie and the
/// wavy bottom edge. The Lotties are drawn for exactly this 390 × 500 area.
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    required this.lottie,
    required this.isActive,
    this.onBack,
    this.onSkip,
  });

  final String lottie;
  final bool isActive;

  /// Shows a back button; when null the logo is shown instead.
  final VoidCallback? onBack;

  /// Shows the Skip button; hidden when null.
  final VoidCallback? onSkip;

  static const Size _designSize = Size(390, 500);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final height = _designSize.height.r;

    return SizedBox(
      height: height,
      child: ColoredBox(
        color: AppColors.blush,
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: OnboardingIllustration(
                  asset: lottie,
                  isActive: isActive,
                  size: Size(_designSize.width.r, height),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -1,
              child: SvgPicture.asset(
                AppImages.headerWave,
                height: 26.r,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: topInset + 8.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  if (onBack == null)
                    SvgPicture.asset(
                      AppImages.logoMarkRed,
                      width: 46.r,
                      height: 33.r,
                    )
                  else
                    _BackButton(onPressed: onBack!),
                  const Spacer(),
                  if (onSkip != null) _SkipButton(onPressed: onSkip!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: context.l10n.back,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.white,
        fixedSize: Size.square(44.r),
        padding: EdgeInsets.zero,
      ),
      icon: AppSvgIcon(
        AppIcons.arrowLeft,
        size: 20.r,
        color: AppColors.ink,
        matchTextDirection: true,
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        minimumSize: Size(0, 44.r),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        shape: const StadiumBorder(),
        textStyle: context.textTheme.labelLarge?.copyWith(fontSize: 15.sp),
      ),
      child: Text(context.l10n.skip),
    );
  }
}
