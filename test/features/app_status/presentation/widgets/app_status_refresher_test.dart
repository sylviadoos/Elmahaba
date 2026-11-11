import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/app_status/domain/entities/app_status_entity.dart';
import 'package:al_mahhaba_school/features/app_status/domain/use_cases/get_app_status_use_case.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_bloc.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/widgets/app_status_refresher.dart';

import '../../../../helpers/result_dummy.dart';
import 'app_status_refresher_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GetAppStatusUseCase>()])
void main() {
  late MockGetAppStatusUseCase getAppStatus;

  /// How often it asks again; one tick is this plus a moment.
  const everyFiveMinutes = Duration(minutes: 5, seconds: 1);

  setUpAll(() => provideResultDummy<AppStatusEntity>());

  void answerWith({required bool enabled}) => when(
    getAppStatus(),
  ).thenAnswer((_) async => Success(data: AppStatusEntity(enabled: enabled)));

  setUp(() {
    getAppStatus = MockGetAppStatusUseCase();
    answerWith(enabled: false);
  });

  /// The app, showing "Log in" while the school says parents may.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppStatusBloc(getAppStatus),
        child: AppStatusRefresher(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: context.select<AppStatusBloc, bool>((bloc) => bloc.state)
                    ? const Text('Log in')
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// The parent leaves the app and comes back to it.
  Future<void> leaveAndReturn(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  }

  testWidgets('the school opens log in: the button shows, no restart', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Log in'), findsNothing);

    answerWith(enabled: true);
    await tester.pump(everyFiveMinutes);
    await tester.pump();

    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('the school closes it again: the button goes', (tester) async {
    answerWith(enabled: true);
    await pumpApp(tester);
    await tester.pump(everyFiveMinutes);
    await tester.pump();
    expect(find.text('Log in'), findsOneWidget);

    answerWith(enabled: false);
    await tester.pump(everyFiveMinutes);
    await tester.pump();

    expect(find.text('Log in'), findsNothing);
  });

  testWidgets('back in the app: it asks at once', (tester) async {
    await pumpApp(tester);

    answerWith(enabled: true);
    await leaveAndReturn(tester);
    await tester.pump();

    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('away from the app: it stops asking', (tester) async {
    await pumpApp(tester);
    clearInteractions(getAppStatus);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    await tester.pump(everyFiveMinutes);

    verifyNever(getAppStatus());
  });

  testWidgets('gone from the screen: it stops asking', (tester) async {
    await pumpApp(tester);
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    clearInteractions(getAppStatus);

    await tester.pump(everyFiveMinutes);

    verifyNever(getAppStatus());
  });
}
