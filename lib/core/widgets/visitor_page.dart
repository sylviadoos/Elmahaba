import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// Layout shared by the visitor pages: a [header] that scrolls with the
/// page, the page sections, and a "Log in" button pinned to the bottom.
class VisitorPage extends StatelessWidget {
  const VisitorPage({
    super.key,
    required this.header,
    required this.children,
    this.spacing = 24,
    this.topPadding = 8,
  });

  final Widget header;
  final List<Widget> children;

  /// Gap between sections, in design pixels.
  final double spacing;

  /// Gap between the header and the first section, in design pixels.
  final double topPadding;

  static const double _buttonHeight = 56;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final buttonBottom = math.max(28.h, bottomInset + 12);
    const showLogin = AppConfig.parentAccountEnabled;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      topPadding.h,
                      20.w,
                      showLogin
                          // Room to scroll the last section above the button.
                          ? buttonBottom + _buttonHeight.h + 26.h
                          : math.max(32.h, bottomInset + 16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: spacing.h,
                      children: children,
                    ),
                  ),
                ],
              ),
            ),
            if (showLogin)
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: buttonBottom,
                child: const _LoginButton(height: _buttonHeight),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.r);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.mahabbahRed.withValues(alpha: 0.28),
            offset: Offset(0, 14.h),
            blurRadius: 30.r,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => context.push(AppRoutes.login),
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(height.h),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10.w,
          children: [
            AppSvgIcon(AppIcons.logIn, size: 20.r, matchTextDirection: true),
            Text(context.l10n.login),
          ],
        ),
      ),
    );
  }
}
