import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/session_status.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/check_session_use_case.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/splash/presentation/pages/splash_page.dart';

import '../../../../helpers/test_app.dart';
import 'splash_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CheckSessionUseCase>(),
  MockSpec<ParentViewModel>(),
  MockSpec<ChildrenViewModel>(),
])
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  late MockCheckSessionUseCase checkSession;
  late MockParentViewModel parentViewModel;
  late MockChildrenViewModel childrenViewModel;

  setUp(() {
    checkSession = MockCheckSessionUseCase();
    parentViewModel = MockParentViewModel();
    childrenViewModel = MockChildrenViewModel();
    getIt.registerSingleton<CheckSessionUseCase>(checkSession);
  });

  tearDown(getIt.reset);

  /// The splash, with a stand-in for each page it opens: a page showing its
  /// path.
  Future<void> pumpSplash(WidgetTester tester) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
        for (final path in [
          AppRoutes.onboarding,
          AppRoutes.home,
          AppRoutes.login,
        ])
          GoRoute(
            path: path,
            builder: (_, _) => Scaffold(body: Text(path)),
          ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TestApp(
        router: router,
        providers: [
          BlocProvider<ParentViewModel>.value(value: parentViewModel),
          BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
        ],
      ),
    );
  }

  /// Opens the next page once [elapsed] passed since the splash showed.
  Future<void> leaveSplash(
    WidgetTester tester, {
    Duration elapsed = const Duration(seconds: 3),
  }) async {
    await tester.pump(elapsed);
    await tester.pump(); // router builds the next page
    await tester.pump(const Duration(seconds: 1)); // page transition
  }

  testWidgets('shows the footer for 3 seconds while checking the session', (
    tester,
  ) async {
    when(checkSession()).thenAnswer((_) async => SessionStatus.none);
    await pumpSplash(tester);

    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.text('Powered by Petra Software'), findsOneWidget);
    verify(checkSession()).called(1);

    await tester.pump(const Duration(milliseconds: 2900));
    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.text(AppRoutes.onboarding), findsNothing);

    await leaveSplash(tester, elapsed: const Duration(milliseconds: 100));
    expect(find.byType(SplashPage), findsNothing);
  });

  group('after the splash', () {
    testWidgets('never signed in: opens onboarding', (tester) async {
      when(checkSession()).thenAnswer((_) async => SessionStatus.none);
      await pumpSplash(tester);
      await leaveSplash(tester);

      expect(find.text(AppRoutes.onboarding), findsOneWidget);
      verifyNever(parentViewModel.doAction(any));
      verifyNever(childrenViewModel.doAction(any));
    });

    testWidgets('signed in: shows the saved parent and children, opens Home', (
      tester,
    ) async {
      when(checkSession()).thenAnswer((_) async => SessionStatus.active);
      await pumpSplash(tester);
      await leaveSplash(tester);

      expect(find.text(AppRoutes.home), findsOneWidget);
      verify(
        parentViewModel.doAction(argThat(isA<ShowSavedParentEvent>())),
      ).called(1);
      verify(
        childrenViewModel.doAction(argThat(isA<LoadChildrenEvent>())),
      ).called(1);
    });

    testWidgets('session ended: opens Log in and says why', (tester) async {
      when(checkSession()).thenAnswer((_) async => SessionStatus.ended);
      await pumpSplash(tester);
      await leaveSplash(tester);

      expect(find.text(AppRoutes.login), findsOneWidget);
      expect(find.text(l10n.expiredToken), findsOneWidget);
      verifyNever(parentViewModel.doAction(any));
      verifyNever(childrenViewModel.doAction(any));
    });

    testWidgets('slow server: waits 5 seconds at most, keeps the session', (
      tester,
    ) async {
      // Never answers.
      when(checkSession()).thenAnswer((_) => Completer<SessionStatus>().future);
      await pumpSplash(tester);

      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(SplashPage), findsOneWidget);

      await leaveSplash(tester, elapsed: const Duration(seconds: 2));
      expect(find.text(AppRoutes.home), findsOneWidget);
      verify(
        parentViewModel.doAction(argThat(isA<ShowSavedParentEvent>())),
      ).called(1);
      verify(
        childrenViewModel.doAction(argThat(isA<LoadChildrenEvent>())),
      ).called(1);
    });
  });
}
