import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';

/// Brand-red header with a faded, tilted logo in the corner and a wavy
/// bottom edge. [child] is laid out below the status bar.
class RedHeader extends StatelessWidget {
  const RedHeader({
    super.key,
    required this.child,
    this.horizontalPadding = 20,
    this.bottomPadding = 46,
    this.watermarkTop = 30,
    this.watermarkSize = const Size(220, 157),
    this.waveColor = AppColors.white,
  });

  final Widget child;

  /// Design values, in pixels of the 390 px wide frame.
  final double horizontalPadding;
  final double bottomPadding;
  final double watermarkTop;
  final Size watermarkSize;

  /// Color of the page below, which the wave blends into.
  final Color waveColor;

  /// Status bar height in the design frames (iPhone); design `top` values
  /// include it.
  static const double designStatusBar = 47;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return ClipRect(
      child: ColoredBox(
        color: AppColors.mahabbahRed,
        child: Stack(
          children: [
            PositionedDirectional(
              end: -46.w,
              top: topInset + (watermarkTop - designStatusBar).h,
              child: HeaderWatermark(size: watermarkSize),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding.w,
                topInset + 8.h,
                horizontalPadding.w,
                bottomPadding.h,
              ),
              child: child,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -1,
              child: HeaderWave(color: waveColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// The faded, tilted logo in the corner of the red headers. Faded in its
/// own colors, not by an `Opacity` over it, which would paint it off screen
/// first every time the header is painted.
class HeaderWatermark extends StatelessWidget {
  const HeaderWatermark({super.key, required this.size});

  /// Design pixels.
  final Size size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: -12 * math.pi / 180,
        child: SvgPicture.asset(
          AppImages.logoMarkWatermark,
          width: size.width.r,
          height: size.height.r,
        ),
      ),
    );
  }
}

/// Wavy bottom edge of the red headers, in the [color] of the page below.
/// White and the surface color have their own drawing; any other is tinted,
/// which paints it off screen first.
class HeaderWave extends StatelessWidget {
  const HeaderWave({super.key, this.color = AppColors.white});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final asset = switch (color) {
      AppColors.white => AppImages.headerWave,
      AppColors.surface => AppImages.headerWaveSurface,
      _ => null,
    };
    return SvgPicture.asset(
      asset ?? AppImages.headerWave,
      height: 26.r,
      fit: BoxFit.fill,
      colorFilter: asset == null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }
}
