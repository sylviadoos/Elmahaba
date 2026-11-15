import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/shell/presentation/pages/parent_shell_page.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../../announcements/announcements_fixtures.dart' show omar;
import '../../../auth/auth_mocks.mocks.dart';
import '../../../chat/chat_mocks.mocks.dart';
import '../../../home/home_mocks.mocks.dart';

void main() {
  late GoRouter router;
  late MockGetNewMessagesCountUseCase getChatUnread;

  setUpAll(() {
    provideResultDummy<int>();
  });

  setUp(() {
    getChatUnread = MockGetNewMessagesCountUseCase();
    when(getChatUnread(any)).thenAnswer((_) async => const Success(data: 0));
    final childrenViewModel = MockChildrenViewModel();
    when(
      childrenViewModel.state,
    ).thenReturn(const ChildrenState(children: BaseState.success([omar])));
    when(childrenViewModel.stream).thenAnswer((_) => const Stream.empty());
    router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        StatefulShellRoute.indexedStack(
          // The badges' blocs sit above the router in `app.dart`; here
          // they only need to be above the shell.
          builder: (_, _, shell) => MultiBlocProvider(
            providers: [
              BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
              BlocProvider(
                create: (_) =>
                    ChatUnreadBloc(getChatUnread, MockWatchChatReadsUseCase()),
              ),
            ],
            child: ParentShellPage(navigationShell: shell),
          ),
          branches: [
            for (final path in [
              AppRoutes.home,
              AppRoutes.results,
              AppRoutes.attendance,
              AppRoutes.fees,
            ])
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: path,
                    builder: (_, _) => Scaffold(body: Text(path)),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
  });

  Future<void> pumpShell(WidgetTester tester, {String? openTab}) async {
    tester.usePhoneScreen();
    await tester.pumpWidget(TestApp(router: router));
    await tester.pumpAndSettle();
    if (openTab == null) return;
    router.go(openTab);
    await tester.pumpAndSettle();
  }

  /// Presses the phone's back button; true when nothing in the app took
  /// it, so Android closes the app.
  Future<bool> pressBack(WidgetTester tester) async {
    var leftTheApp = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemNavigator.pop') leftTheApp = true;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    return leftTheApp;
  }

  testWidgets('another tab: back shows Home, and stays in the app', (
    tester,
  ) async {
    await pumpShell(tester, openTab: AppRoutes.fees);
    expect(find.text(AppRoutes.fees), findsOneWidget);

    expect(await pressBack(tester), isFalse);

    expect(find.text(AppRoutes.home), findsOneWidget);
  });

  testWidgets('on Home: back leaves the app, as always', (tester) async {
    await pumpShell(tester);

    expect(await pressBack(tester), isTrue);
  });

  testWidgets('back twice from a tab: Home, then out of the app', (
    tester,
  ) async {
    await pumpShell(tester, openTab: AppRoutes.attendance);

    expect(await pressBack(tester), isFalse);
    expect(find.text(AppRoutes.home), findsOneWidget);

    expect(await pressBack(tester), isTrue);
  });
}
