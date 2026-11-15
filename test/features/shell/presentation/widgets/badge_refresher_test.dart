import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/badge_refresher.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../announcements/announcements_fixtures.dart' show lina, omar;
import '../../../auth/auth_fixtures.dart';
import '../../../auth/auth_mocks.mocks.dart';
import '../../../chat/chat_mocks.mocks.dart';
import '../../../home/home_mocks.mocks.dart';

/// Firebase isn't set up in tests: pushes arrive when [arrive] is called.
class _Pushes implements NotificationService {
  final _received = StreamController<Map<String, dynamic>>.broadcast();

  void arrive() => _received.add(const {'type': 'message'});

  Future<void> close() => _received.close();

  @override
  Stream<Map<String, dynamic>> get onReceived => _received.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late _Pushes pushes;
  late MockGetNewMessagesCountUseCase getChatUnread;
  late MockParentViewModel parentViewModel;
  late MockChildrenViewModel childrenViewModel;
  late StreamController<ChildrenState> children;

  /// Omar's shown on every page.
  const omarShown = ChildrenState(
    children: BaseState.success([omar, lina]),
    selectedId: 1208,
  );

  setUpAll(() {
    provideResultDummy<int>();
    provideResultDummy<bool>();
  });

  setUp(() {
    pushes = _Pushes();
    getChatUnread = MockGetNewMessagesCountUseCase();
    parentViewModel = MockParentViewModel();
    childrenViewModel = MockChildrenViewModel();
    children = StreamController.broadcast();
    addTearDown(children.close);
    when(childrenViewModel.state).thenReturn(omarShown);
    when(childrenViewModel.stream).thenAnswer((_) => children.stream);
    when(getChatUnread(any)).thenAnswer((_) async => const Success(data: 3));
    getIt.registerSingleton<NotificationService>(pushes);
    addTearDown(getIt.reset);
    addTearDown(pushes.close);
  });

  /// The app around the badges, with the parent signed in or not.
  Future<void> pumpApp(WidgetTester tester, {required bool signedIn}) async {
    when(parentViewModel.state).thenReturn(
      signedIn ? BaseState.success(parent) : const BaseState.initial(),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ParentViewModel>.value(value: parentViewModel),
          BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
          BlocProvider(
            create: (_) =>
                ChatUnreadBloc(getChatUnread, MockWatchChatReadsUseCase()),
          ),
        ],
        child: const BadgeRefresher(
          child: MaterialApp(home: Scaffold(body: Text('Home'))),
        ),
      ),
    );
  }

  /// The parent leaves the app and comes back to it.
  Future<void> leaveAndReturn(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  }

  void verifyAsked({required int times}) {
    // The chat's count is the child shown's: the school asks for one.
    verify(getChatUnread(1208)).called(times);
  }

  testWidgets('nothing is asked until something happens', (tester) async {
    await pumpApp(tester, signedIn: true);

    verifyNever(getChatUnread(any));
  });

  testWidgets('another child picked: the chat badge asks for theirs', (
    tester,
  ) async {
    await pumpApp(tester, signedIn: true);

    const linaShown = ChildrenState(
      children: BaseState.success([omar, lina]),
      selectedId: 1209,
    );
    when(childrenViewModel.state).thenReturn(linaShown);
    children.add(linaShown);
    await tester.pump();

    verify(getChatUnread(1209)).called(1);
  });

  testWidgets('a notification arrives: the badge asks what is new', (
    tester,
  ) async {
    await pumpApp(tester, signedIn: true);

    pushes.arrive();
    await tester.pump();

    verifyAsked(times: 1);
  });

  testWidgets('back in the app: asks again, for what arrived meanwhile', (
    tester,
  ) async {
    await pumpApp(tester, signedIn: true);

    await leaveAndReturn(tester);

    verifyAsked(times: 1);
  });

  testWidgets('a visitor: nothing is asked, the API would refuse', (
    tester,
  ) async {
    await pumpApp(tester, signedIn: false);

    pushes.arrive();
    await tester.pump();
    await leaveAndReturn(tester);

    verifyNever(getChatUnread(any));
  });

  testWidgets('gone from the screen: it stops listening', (tester) async {
    await pumpApp(tester, signedIn: true);
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    pushes.arrive();
    await tester.pump();

    verifyNever(getChatUnread(any));
  });
}
