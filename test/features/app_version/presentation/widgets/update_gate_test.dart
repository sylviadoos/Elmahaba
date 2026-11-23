import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/theme/app_theme.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/widgets/screen_util_scope.dart';
import 'package:al_mahhaba_school/features/app_version/domain/entities/app_version_entity.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/bloc/app_version_bloc.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/widgets/update_gate.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../app_version_fixtures.dart';
import '../../app_version_mocks.mocks.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  late MockCheckAppVersionUseCase checkAppVersion;
  late MockGetSavedForcedUpdateUseCase getSavedForcedUpdate;
  late List<String> opened;

  setUpAll(() => provideResultDummy<AppVersionEntity>());

  setUp(() {
    checkAppVersion = MockCheckAppVersionUseCase();
    getSavedForcedUpdate = MockGetSavedForcedUpdateUseCase();
    opened = [];
    when(getSavedForcedUpdate()).thenAnswer((_) async => null);
  });

  void schoolSays(AppVersionEntity update) =>
      when(checkAppVersion()).thenAnswer((_) async => Success(data: update));

  /// The app as `app.dart` builds it: a page under the gate.
  Future<void> pump(WidgetTester tester) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ScreenUtilScope(
        child: BlocProvider(
          create: (_) => AppVersionBloc(checkAppVersion, getSavedForcedUpdate),
          child: Builder(
            builder: (_) => MaterialApp.router(
              theme: AppTheme.light(const Locale('en')),
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
              builder: (context, child) => UpdateGate(
                openStore: (url) async => opened.add(url),
                child: child!,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('up to date: the app as usual', (tester) async {
    schoolSays(upToDate);
    await pump(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text(en.updateNow), findsNothing);
  });

  group('forced', () {
    testWidgets('the card instead of the app: Update only', (tester) async {
      schoolSays(forced);
      await pump(tester);

      expect(find.text(en.updateRequired), findsOneWidget);
      expect(find.text(forced.message), findsOneWidget);
      expect(find.text(en.updateLater), findsNothing);
      // Nothing of the app is there to reach.
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('Update opens the store page', (tester) async {
      schoolSays(forced);
      await pump(tester);

      await tester.tap(find.text(en.updateNow));
      await tester.pump();

      expect(opened, [forced.storeUrl]);
    });

    testWidgets('back, a tap beside it, back from the store: still there', (
      tester,
    ) async {
      schoolSays(forced);
      await pump(tester);

      await tester.binding.handlePopRoute();
      await tester.tapAt(const Offset(8, 8));
      await tester.tap(find.text(en.updateNow));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(find.text(en.updateRequired), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('kept from before, the school out of reach: still forced', (
      tester,
    ) async {
      when(getSavedForcedUpdate()).thenAnswer((_) async => forced);
      when(
        checkAppVersion(),
      ).thenAnswer((_) async => const Failure(exception: NetworkException()));
      await pump(tester);

      expect(find.text(en.updateRequired), findsOneWidget);
    });

    testWidgets("no message from the school: the app's own", (tester) async {
      schoolSays(
        const AppVersionEntity(updateAvailable: true, forceUpdate: true),
      );
      await pump(tester);

      expect(find.text(en.updateRequiredMessage), findsOneWidget);
    });
  });

  group('optional', () {
    testWidgets('the card over the app, with Later', (tester) async {
      schoolSays(optional);
      await pump(tester);

      expect(find.text(en.updateAvailable), findsOneWidget);
      expect(find.text(en.updateLater), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('a tap beside it: still there', (tester) async {
      schoolSays(optional);
      await pump(tester);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(find.text(en.updateAvailable), findsOneWidget);
    });

    testWidgets('Later: gone, the app as it was', (tester) async {
      schoolSays(optional);
      await pump(tester);

      await tester.tap(find.text(en.updateLater));
      await tester.pumpAndSettle();

      expect(find.text(en.updateAvailable), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  testWidgets("the school out of reach, nothing kept: the app as usual", (
    tester,
  ) async {
    when(
      checkAppVersion(),
    ).thenAnswer((_) async => const Failure(exception: NetworkException()));
    await pump(tester);

    expect(find.text('Home'), findsOneWidget);
  });
}
