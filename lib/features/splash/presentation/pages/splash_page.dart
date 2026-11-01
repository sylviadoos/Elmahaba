import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/constants/app_constants.dart';

/// Brand splash: the Lottie (rings, hands, heart and school name) loops over
/// the brand red, with the footer underneath. Opens onboarding after
/// [_duration]; replace with the real start-up logic (Cubit) later.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Duration _duration = Duration(seconds: 3);

  /// Logo center as a fraction of the screen height (361 / 844 in the design).
  static const double _logoCenter = 361 / 844;

  /// splash.json canvas, in Lottie units. Its 1080 units span the 390 px
  /// design width. (The original is 1080 × 1080; 40 units were added on top
  /// so the breathing outer ring isn't clipped.)
  static const Size _lottieCanvas = Size(1080, 1120);

  /// Logo (rings) center inside splash.json, in Lottie units.
  static const double _lottieLogoY = 411.1;

  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_duration, () {
      if (mounted) context.go(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Pixels per Lottie unit. The Lottie background is the same red as the
    // page, so its edges don't show.
    final scale = AppConstants.designSize.width.r / _lottieCanvas.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.mahabbahRed,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final logoCenterY = constraints.maxHeight * _logoCenter;

            return Stack(
              children: [
                Positioned(
                  top: logoCenterY - _lottieLogoY * scale,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Lottie.asset(
                      AppLottie.splash,
                      width: _lottieCanvas.width * scale,
                      height: _lottieCanvas.height * scale,
                    ),
                  ),
                ),
                Positioned(
                  bottom: math.max(48.h, bottomInset + 16),
                  left: 0,
                  right: 0,
                  child: Text(
                    'Powered by Petra Software',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize: 13.sp,
                      color: AppColors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
