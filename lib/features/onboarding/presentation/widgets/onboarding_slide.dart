import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/onboarding/presentation/widgets/onboarding_header.dart';
import 'package:al_mahhaba_school/features/onboarding/presentation/widgets/page_dots.dart';

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.lottie,
    required this.title,
    required this.body,
  });

  final String lottie;
  final String title;
  final String body;
}

/// One onboarding screen: the illustrated header, then the text and buttons.
///
/// The first slide shows the logo instead of a back button, and the last one
/// has "Get started" instead of Skip / Next.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.data,
    required this.index,
    required this.count,
    required this.isActive,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
    required this.onGetStarted,
  });

  final OnboardingSlideData data;
  final int index;
  final int count;

  /// Whether this slide is the one on screen (plays its animation).
  final bool isActive;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onGetStarted;

  bool get _isFirst => index == 0;
  bool get _isLast => index == count - 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final arrow = AppSvgIcon(
      AppIcons.arrowRight,
      size: 20.r,
      matchTextDirection: true,
    );

    return Column(
      children: [
        OnboardingHeader(
          lottie: data.lottie,
          isActive: isActive,
          onBack: _isFirst ? null : onBack,
          onSkip: _isLast ? null : onSkip,
        ),
        Expanded(
          // Scrolls only if the text doesn't fit (small phones, large fonts);
          // otherwise the buttons sit at the bottom.
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      28.w,
                      28.h,
                      28.w,
                      math.max(40.h, bottomInset + 16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageDots(count: count, current: index),
                        SizedBox(height: 14.h),
                        Text(data.title, style: textTheme.headlineMedium),
                        SizedBox(height: 14.h),
                        Text(
                          data.body,
                          style: textTheme.bodyLarge?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        const Spacer(),
                        if (_isLast)
                          AppButton(
                            label: l10n.getStarted,
                            onPressed: onGetStarted,
                            trailingIcon: arrow,
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.pageXOfY(index + 1, count),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                              AppButton(
                                label: l10n.next,
                                onPressed: onNext,
                                trailingIcon: arrow,
                                expand: false,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
