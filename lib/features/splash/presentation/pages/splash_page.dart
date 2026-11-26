import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_bloc.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_intent.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/session_status.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/check_session_use_case.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

/// Brand splash: the Lottie (rings, hands, heart and school name) loops over
/// the brand red, with the footer underneath. Meanwhile it checks the saved
/// session, then opens Home (signed in), Log in (session ended) or
/// onboarding (never signed in).
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

  /// A slow or unreachable server mustn't keep the parent here: past this,
  /// the session is kept.
  static const Duration _maxSessionCheck = Duration(seconds: 5);

  late final Timer _timer;

  /// Checked while the splash shows, so it's ready when it ends.
  late final Future<SessionStatus> _session;

  @override
  void initState() {
    super.initState();
    _session = getIt<CheckSessionUseCase>()().timeout(
      _maxSessionCheck,
      onTimeout: () => SessionStatus.active,
    );
    // A visitor: whether "Log in" shows, asked now so it's known by the
    // first visitor page. A signed-in parent isn't asked: only the
    // visitors' button depends on it.
    unawaited(
      _session.then((session) {
        if (session != SessionStatus.active && mounted) {
          context.read<AppStatusBloc>().add(const LoadAppStatusIntent());
        }
      }),
    );
    _timer = Timer(_duration, _leave);
  }

  Future<void> _leave() async {
    final session = await _session;
    if (!mounted) return;
    if (session == SessionStatus.active) {
      context.read<ParentViewModel>().doAction(const ShowSavedParentEvent());
      // Saved children show at once; the API refreshes them once, quietly.
      context.read<ChildrenViewModel>().doAction(const LoadChildrenEvent());
    }
    // Shown on Log in: the messenger outlives this page.
    final l10n = context.l10n;
    switch (session) {
      case SessionStatus.ended:
        context.showSnackBar(l10n.expiredToken, isError: true);
      case SessionStatus.replaced:
        context.showSnackBar(l10n.sessionReplaced, isError: true);
      case SessionStatus.withdrawn:
        context.showSnackBar(l10n.accountWithdrawn, isError: true);
      case SessionStatus.none || SessionStatus.active:
        break;
    }
    context.go(switch (session) {
      SessionStatus.none => AppRoutes.onboarding,
      SessionStatus.active => AppRoutes.home,
      SessionStatus.ended ||
      SessionStatus.replaced ||
      SessionStatus.withdrawn => AppRoutes.login,
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
