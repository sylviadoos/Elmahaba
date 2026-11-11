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
import 'package:al_mahhaba_school/features/complaints/presentation/bloc/complaint_updates_bloc.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/badge_refresher.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../auth/auth_fixtures.dart';
import '../../../auth/auth_mocks.mocks.dart';
import '../../../chat/chat_mocks.mocks.dart';
import '../../../complaints/complaints_mocks.mocks.dart';

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
  late MockGetChatUnreadCountUseCase getChatUnread;
  late MockHasNewComplaintUpdatesUseCase hasNewComplaints;
  late MockMarkComplaintsSeenUseCase markComplaintsSeen;
  late MockParentViewModel parentViewModel;

  setUpAll(() {
    provideResultDummy<int>();
    provideResultDummy<bool>();
  });

  setUp(() {
    pushes = _Pushes();
    getChatUnread = MockGetChatUnreadCountUseCase();
    hasNewComplaints = MockHasNewComplaintUpdatesUseCase();
    markComplaintsSeen = MockMarkComplaintsSeenUseCase();
    parentViewModel = MockParentViewModel();
    when(getChatUnread()).thenAnswer((_) async => const Success(data: 3));
    when(hasNewComplaints()).thenAnswer((_) async => const Success(data: true));
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
          BlocProvider(
            create: (_) =>
                ChatUnreadBloc(getChatUnread, MockWatchChatReadsUseCase()),
          ),
          BlocProvider(
            create: (_) =>
                ComplaintUpdatesBloc(hasNewComplaints, markComplaintsSeen),
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
    verify(getChatUnread()).called(times);
    verify(hasNewComplaints()).called(times);
  }

  testWidgets('nothing is asked until something happens', (tester) async {
    await pumpApp(tester, signedIn: true);

    verifyNever(getChatUnread());
    verifyNever(hasNewComplaints());
  });

  testWidgets('a notification arrives: both badges ask what is new', (
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

    verifyNever(getChatUnread());
    verifyNever(hasNewComplaints());
  });

  testWidgets('gone from the screen: it stops listening', (tester) async {
    await pumpApp(tester, signedIn: true);
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    pushes.arrive();
    await tester.pump();

    verifyNever(getChatUnread());
    verifyNever(hasNewComplaints());
  });
}
