import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:al_mahhaba_school/app.dart';
import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_router.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/login_page.dart';
import 'package:al_mahhaba_school/features/chat/presentation/pages/chat_page.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pages/fees_page.dart';
import 'package:al_mahhaba_school/features/home/presentation/pages/home_page.dart';
import 'package:al_mahhaba_school/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:al_mahhaba_school/features/results/presentation/pages/results_page.dart';
import 'package:al_mahhaba_school/features/splash/presentation/pages/splash_page.dart';
import 'package:al_mahhaba_school/features/about/presentation/pages/about_page.dart';
import 'package:al_mahhaba_school/features/explore/presentation/pages/explore_page.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(); // router builds the next page
    await tester.pump(const Duration(seconds: 1)); // page transition
  }

  testWidgets('Visitor: splash → onboarding → Explore → About and back', (
    tester,
  ) async {
    await tester.pumpWidget(const AlMahhabaApp());
    // Lottie files load asynchronously.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pump();

    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.text('Powered by Petra Software'), findsOneWidget);

    // Still on the splash just before 3 seconds.
    await tester.pump(const Duration(milliseconds: 2900));
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100)); // 3s: timer fires
    await settle(tester);

    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('Follow your child’s grades'), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await settle(tester);

    expect(find.byType(ExplorePage), findsOneWidget);
    expect(find.text('Why families choose us'), findsOneWidget);

    await tester.tap(find.text('About us').first);
    await settle(tester);

    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text('Our mission'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await settle(tester);

    expect(find.byType(AboutPage), findsNothing);
    expect(find.byType(ExplorePage), findsOneWidget);

    if (AppConfig.parentAccountEnabled) {
      expect(find.text('Log in'), findsOneWidget);
    } else {
      // Visitor-only: no Log in button, and parent screens can't be opened.
      expect(find.text('Log in'), findsNothing);
      appRouter.go(AppRoutes.login);
      await settle(tester);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(ExplorePage), findsOneWidget);
    }
  });

  // Runs with `flutter test --dart-define=PARENT_ACCOUNT=true`.
  testWidgets(
    'Parent: Log in → Home → Chat → tabs',
    skip: !AppConfig.parentAccountEnabled,
    (tester) async {
      await tester.pumpWidget(const AlMahhabaApp());
      appRouter.go(AppRoutes.login);
      await settle(tester);
      expect(find.byType(LoginPage), findsOneWidget);

      // No real authentication yet.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
      await settle(tester);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Needs your attention'), findsOneWidget);

      await tester.tap(find.text('Reply: bring the Science book tomorrow'));
      await settle(tester);
      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.text('You replied'), findsOneWidget);

      // Back to Home, then switch tabs from the nav bar.
      await tester.tap(find.byTooltip('Back'));
      await settle(tester);
      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.text('Results').last);
      await settle(tester);
      expect(find.byType(ResultsPage), findsOneWidget);
      expect(find.text('Subjects'), findsOneWidget);

      await tester.tap(find.text('Fees').last);
      await settle(tester);
      expect(find.byType(FeesPage), findsOneWidget);
      expect(find.text('Installments'), findsOneWidget);
    },
  );
}
