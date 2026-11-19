import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/app_status/domain/entities/app_status_entity.dart';
import 'package:al_mahhaba_school/features/app_status/domain/use_cases/get_app_status_use_case.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_bloc.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/widgets/app_status_refresher.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../auth/auth_fixtures.dart' show parent;
import 'app_status_refresher_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GetAppStatusUseCase>(),
  MockSpec<ParentViewModel>(),
])
void main() {
  late MockGetAppStatusUseCase getAppStatus;
  late MockParentViewModel parentViewModel;
  late StreamController<ParentState> parentChanges;

  /// A visitor: nobody signed in.
  const visitor = BaseState<ParentEntity>.initial();
  final signedIn = BaseState.success(parent);

  /// How often it asks again; one tick is this plus a moment.
  const everyFiveMinutes = Duration(minutes: 5, seconds: 1);

  setUpAll(() => provideResultDummy<AppStatusEntity>());

  void answerWith({required bool enabled}) => when(
    getAppStatus(),
  ).thenAnswer((_) async => Success(data: AppStatusEntity(enabled: enabled)));

  setUp(() {
    getAppStatus = MockGetAppStatusUseCase();
    answerWith(enabled: false);
    parentViewModel = MockParentViewModel();
    parentChanges = StreamController.broadcast();
    addTearDown(parentChanges.close);
    when(parentViewModel.state).thenReturn(visitor);
    when(parentViewModel.stream).thenAnswer((_) => parentChanges.stream);
  });

  /// [state] is who's using the app now.
  void becomes(ParentState state) {
    when(parentViewModel.state).thenReturn(state);
    parentChanges.add(state);
  }

  /// The app, showing "Log in" while the school says parents may.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ParentViewModel>.value(value: parentViewModel),
          BlocProvider(create: (_) => AppStatusBloc(getAppStatus)),
        ],
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

  testWidgets('a parent signed in: never asked — the app works whatever '
      'the school says', (tester) async {
    when(parentViewModel.state).thenReturn(signedIn);
    await pumpApp(tester);
    clearInteractions(getAppStatus);

    await tester.pump(everyFiveMinutes);
    await leaveAndReturn(tester);
    await tester.pump(everyFiveMinutes);

    verifyNever(getAppStatus());
  });

  testWidgets('the parent logs out: asked at once, for the visitor pages', (
    tester,
  ) async {
    when(parentViewModel.state).thenReturn(signedIn);
    await pumpApp(tester);
    answerWith(enabled: true);

    becomes(visitor);
    await tester.pump();
    await tester.pump();

    verify(getAppStatus()).called(1);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('gone from the screen: it stops asking', (tester) async {
    await pumpApp(tester);
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    clearInteractions(getAppStatus);

    await tester.pump(everyFiveMinutes);

    verifyNever(getAppStatus());
  });
}
