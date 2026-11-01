import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/onboarding/presentation/widgets/onboarding_slide.dart';

/// Three swipeable intro screens: grades, daily lessons, fees.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: AppConstants.animationDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() => context.go(AppRoutes.explore);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slides = [
      OnboardingSlideData(
        lottie: AppLottie.onboarding1Grades,
        title: l10n.onboardingGradesTitle,
        body: l10n.onboardingGradesBody,
      ),
      OnboardingSlideData(
        lottie: AppLottie.onboarding2Learning,
        title: l10n.onboardingLessonsTitle,
        body: l10n.onboardingLessonsBody,
      ),
      OnboardingSlideData(
        lottie: AppLottie.onboarding3Fees,
        title: l10n.onboardingFeesTitle,
        body: l10n.onboardingFeesBody,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: PageView.builder(
          controller: _pageController,
          itemCount: slides.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) => OnboardingSlide(
            data: slides[index],
            index: index,
            count: slides.length,
            isActive: index == _currentIndex,
            onBack: () => _goTo(index - 1),
            onNext: () => _goTo(index + 1),
            onSkip: _finish,
            onGetStarted: _finish,
          ),
        ),
      ),
    );
  }
}
