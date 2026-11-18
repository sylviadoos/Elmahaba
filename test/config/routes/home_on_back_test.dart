import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/routes/home_on_back.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';

import '../../helpers/test_app.dart';

/// A page showing its name, with the arrow its header would have.
class _Page extends StatelessWidget {
  const _Page(this.name);

  final String name;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Column(children: [const AppBackButton(), Text(name)]));
}

/// The chat's photo viewer: over the chat, and back closes it.
const String _photo = '/photo';

/// An excuse, opened from Attendance: back is Attendance.
const String _excuse = '/excuse';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(path: AppRoutes.home, builder: (_, _) => const _Page('Home')),
        for (final path in [
          AppRoutes.chat,
          AppRoutes.fees,
          AppRoutes.announcements,
        ])
          GoRoute(
            path: path,
            builder: (_, _) => HomeOnBack(child: _Page(path)),
          ),
        GoRoute(path: _photo, builder: (_, _) => const _Page(_photo)),
        GoRoute(
          path: AppRoutes.attendance,
          builder: (_, _) => const HomeOnBack(child: _Page('Attendance')),
        ),
        GoRoute(path: _excuse, builder: (_, _) => const _Page(_excuse)),
      ],
    );
    addTearDown(router.dispose);
  });

  /// The parent walks through [paths], ending on the last.
  Future<void> openInTurn(WidgetTester tester, List<String> paths) async {
    tester.usePhoneScreen();
    await tester.pumpWidget(TestApp(router: router));
    for (final path in paths) {
      router.push(path);
      await tester.pumpAndSettle();
    }
  }

  /// The phone's own back button.
  Future<void> pressBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  Future<void> tapTheArrow(WidgetTester tester) async {
    await tester.tap(find.byType(AppBackButton).last);
    await tester.pumpAndSettle();
  }

  group('through several pages, back is Home', () {
    testWidgets('the phone\'s back button', (tester) async {
      await openInTurn(tester, [
        AppRoutes.chat,
        AppRoutes.fees,
        AppRoutes.announcements,
      ]);
      expect(find.text(AppRoutes.announcements), findsOneWidget);

      await pressBack(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text(AppRoutes.fees), findsNothing);
    });

    testWidgets('the arrow in the page', (tester) async {
      await openInTurn(tester, [
        AppRoutes.chat,
        AppRoutes.fees,
        AppRoutes.announcements,
      ]);

      await tapTheArrow(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text(AppRoutes.fees), findsNothing);
    });

    testWidgets('one page deep: Home all the same', (tester) async {
      await openInTurn(tester, [AppRoutes.chat]);

      await pressBack(tester);

      expect(find.text('Home'), findsOneWidget);
    });
  });

  testWidgets('a photo over the chat: back leaves the chat open', (
    tester,
  ) async {
    await openInTurn(tester, [AppRoutes.chat, _photo]);

    await pressBack(tester);

    expect(find.text(AppRoutes.chat), findsOneWidget);
    expect(find.text(_photo), findsNothing);
  });

  testWidgets('its arrow goes back to the chat too', (tester) async {
    await openInTurn(tester, [AppRoutes.chat, _photo]);

    await tapTheArrow(tester);

    expect(find.text(AppRoutes.chat), findsOneWidget);
  });

  group('an excuse, from Attendance: back is Attendance, then Home', () {
    testWidgets("the phone's back button", (tester) async {
      await openInTurn(tester, [AppRoutes.attendance, _excuse]);

      await pressBack(tester);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text(_excuse), findsNothing);

      await pressBack(tester);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('the arrow in the page', (tester) async {
      await openInTurn(tester, [AppRoutes.attendance, _excuse]);

      await tapTheArrow(tester);

      expect(find.text('Attendance'), findsOneWidget);
    });
  });
}
