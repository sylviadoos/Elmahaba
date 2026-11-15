import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations_en.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/widgets/visitor_page.dart';
import 'package:al_mahhaba_school/features/app_status/domain/entities/app_status_entity.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_bloc.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_intent.dart';

import '../../features/app_status/app_status_mocks.mocks.dart';
import '../../helpers/result_dummy.dart';
import '../../helpers/test_app.dart';

final l10n = AppLocalizationsEn();

void main() {
  late MockGetAppStatusUseCase getAppStatus;

  setUpAll(() => provideResultDummy<AppStatusEntity>());

  setUp(() => getAppStatus = MockGetAppStatusUseCase());

  /// A visitor page, once the school answered with [status].
  Future<void> pump(
    WidgetTester tester,
    Result<AppStatusEntity> status, {
    bool showLogin = true,
  }) async {
    tester.usePhoneScreen();
    when(getAppStatus()).thenAnswer((_) async => status);
    final appStatus = AppStatusBloc(getAppStatus)
      ..add(const LoadAppStatusIntent());
    addTearDown(appStatus.close);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => VisitorPage(
            header: const SizedBox(height: 100),
            showLogin: showLogin,
            children: const [Text('Section')],
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TestApp(
        router: router,
        providers: [BlocProvider<AppStatusBloc>.value(value: appStatus)],
      ),
    );
    await tester.pump();
  }

  testWidgets('the school takes parents: Log in', (tester) async {
    await pump(tester, const Success(data: AppStatusEntity(enabled: true)));

    expect(find.text(l10n.login), findsOneWidget);
  });

  testWidgets('it doesn\'t: no Log in', (tester) async {
    await pump(tester, const Success(data: AppStatusEntity(enabled: false)));

    expect(find.text(l10n.login), findsNothing);
    expect(find.text('Section'), findsOneWidget);
  });

  testWidgets('couldn\'t ask: no Log in', (tester) async {
    await pump(tester, const Failure(exception: NetworkException()));

    expect(find.text(l10n.login), findsNothing);
  });

  testWidgets('signed in already: no Log in', (tester) async {
    await pump(
      tester,
      const Success(data: AppStatusEntity(enabled: true)),
      showLogin: false,
    );

    expect(find.text(l10n.login), findsNothing);
  });
}
