import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/notifications/app_icon_badge.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/app_icon_badge_sync.dart';

import '../../../chat/chat_mocks.mocks.dart';
import '../../../home/home_mocks.mocks.dart';

/// No launcher in tests: what would be on the icon, in order.
class _Icon implements AppIconBadge {
  final List<int> shown = [];

  @override
  Future<void> show(int count) async => shown.add(count);
}

void main() {
  late _Icon icon;
  late ChatUnreadBloc chatUnread;

  setUp(() {
    icon = _Icon();
    getIt.registerSingleton<AppIconBadge>(icon);
    addTearDown(getIt.reset);
  });

  // The bloc is made in the test, not in setUp: made outside the
  // test's clock, what it emits would never arrive.
  Future<void> pumpApp(WidgetTester tester) {
    chatUnread = ChatUnreadBloc(
      MockGetNewMessagesCountUseCase(),
      MockWatchChatReadsUseCase(),
    );
    addTearDown(chatUnread.close);
    return tester.pumpWidget(
      BlocProvider.value(
        value: chatUnread,
        child: const AppIconBadgeSync(
          child: MaterialApp(home: Scaffold(body: Text('Home'))),
        ),
      ),
    );
  }

  /// The count on Chat changes, as Home or the school says.
  Future<void> count(WidgetTester tester, int count) async {
    chatUnread.add(SetChatUnreadIntent(count));
    await tester.pump();
  }

  testWidgets('at launch: the icon is put to the app count, '
      "not left with a push's", (tester) async {
    await pumpApp(tester);

    expect(icon.shown, [0]);
  });

  testWidgets('the icon follows the badge on Chat', (tester) async {
    await pumpApp(tester);

    await count(tester, 3);
    await count(tester, 5);

    expect(icon.shown, [0, 3, 5]);
  });

  testWidgets('all read: the number goes off the icon', (tester) async {
    await pumpApp(tester);
    await count(tester, 3);

    await count(tester, 0);

    expect(icon.shown, [0, 3, 0]);
  });

  testWidgets('logged out: the number goes off the icon', (tester) async {
    await pumpApp(tester);
    await count(tester, 4);

    chatUnread.add(const ClearChatUnreadIntent());
    await tester.pump();

    expect(icon.shown, [0, 4, 0]);
  });

  testWidgets('back to the app: the count is put again, unchanged or not '
      '(a push may have changed the icon meanwhile)', (tester) async {
    await pumpApp(tester);
    await count(tester, 2);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(icon.shown, [0, 2, 2]);
  });
}
