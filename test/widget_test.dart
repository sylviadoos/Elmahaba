import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:al_mahhaba_school/app.dart';
import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_router.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/features/app_status/data/data_sources/app_status_remote_data_source.dart';
import 'package:al_mahhaba_school/features/app_status/data/models/app_status_model.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/phone_verification_data_source.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/login_page.dart';
import 'package:al_mahhaba_school/features/chat/presentation/pages/chat_page.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pages/fees_page.dart';
import 'package:al_mahhaba_school/features/home/presentation/pages/home_page.dart';
import 'package:al_mahhaba_school/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:al_mahhaba_school/features/results/presentation/pages/results_page.dart';
import 'package:al_mahhaba_school/features/splash/presentation/pages/splash_page.dart';
import 'package:al_mahhaba_school/features/about/presentation/pages/about_page.dart';
import 'package:al_mahhaba_school/features/explore/presentation/pages/explore_page.dart';

/// Firebase isn't set up in tests; the OTP page that needs it isn't opened.
class _NoPhoneVerification implements PhoneVerificationDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// No server in tests: the school takes parents.
class _ParentsWelcome implements AppStatusRemoteDataSource {
  @override
  Future<AppStatusModel> getAppStatus() async =>
      const AppStatusModel(enabled: true);
}

/// Firebase isn't set up in tests: a phone without pushes.
class _NoNotifications implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<Map<String, dynamic>> get onTap => const Stream.empty();

  @override
  Stream<Map<String, dynamic>> get onReceived => const Stream.empty();

  @override
  Future<void> deleteToken() async {}
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
    getIt
      ..unregister<PhoneVerificationDataSource>()
      ..registerLazySingleton<PhoneVerificationDataSource>(
        _NoPhoneVerification.new,
      )
      ..unregister<NotificationService>()
      ..registerLazySingleton<NotificationService>(_NoNotifications.new)
      ..unregister<AppStatusRemoteDataSource>()
      ..registerLazySingleton<AppStatusRemoteDataSource>(_ParentsWelcome.new);
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

      // Empty fields are caught before calling the API.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
      await settle(tester);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('This field is required'), findsNWidgets(2));

      // Signing in needs the server: open Home directly (no children, so
      // no dashboard to load).
      appRouter.go(AppRoutes.home);
      await settle(tester);
      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.text('Chat'));
      await settle(tester);
      expect(find.byType(ChatPage), findsOneWidget);

      // Back to Home, then switch tabs from the nav bar.
      await tester.tap(find.byTooltip('Back'));
      await settle(tester);
      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.text('Results').last);
      await settle(tester);
      expect(find.byType(ResultsPage), findsOneWidget);

      await tester.tap(find.text('Fees').last);
      await settle(tester);
      expect(find.byType(FeesPage), findsOneWidget);
    },
  );
}
