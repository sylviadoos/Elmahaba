import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/today_banner.dart';

import '../../../../helpers/test_app.dart';

final en = lookupAppLocalizations(const Locale('en'));

void main() {
  Future<void> pump(WidgetTester tester, TodayBanner banner) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(body: banner),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(TestApp(router: router));
  }

  testWidgets('nothing recorded on a holiday: the holiday, by name', (
    tester,
  ) async {
    await pump(
      tester,
      const TodayBanner(status: null, holidayName: '6 October'),
    );

    expect(find.text('${en.officialHoliday} · 6 October'), findsOneWidget);
    expect(find.text(en.attendanceNotTaken), findsNothing);
  });

  testWidgets('a holiday without a name: just that it is one', (tester) async {
    await pump(tester, const TodayBanner(status: null, holidayName: ''));

    expect(find.text(en.officialHoliday), findsOneWidget);
  });

  testWidgets('nothing recorded on a weekly day off: the day off', (
    tester,
  ) async {
    await pump(tester, const TodayBanner(status: null, isWeekend: true));

    expect(find.text(en.friSatOff), findsOneWidget);
  });

  testWidgets('a school day, nothing recorded yet: says so', (tester) async {
    await pump(tester, const TodayBanner(status: null));

    expect(find.text(en.attendanceNotTaken), findsOneWidget);
  });

  testWidgets('recorded: what was recorded, holiday or not', (tester) async {
    await pump(
      tester,
      const TodayBanner(status: 'present', holidayName: '6 October'),
    );

    expect(find.text(en.present), findsOneWidget);
  });
}
