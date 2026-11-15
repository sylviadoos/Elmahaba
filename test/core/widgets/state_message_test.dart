import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/theme/app_theme.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/widgets/screen_util_scope.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';

void main() {
  /// [message] filling a 390 × 600 area, on the design's phone.
  Future<void> pumpIn(WidgetTester tester, Widget message) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilScope(
        child: Builder(
          builder: (_) => MaterialApp(
            theme: AppTheme.light(const Locale('en')),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(width: 390, height: 600, child: message),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// How far the message's middle is from [area]'s, up and down.
  double offCenter(WidgetTester tester, Rect area) =>
      (tester.getRect(find.byType(StateMessage)).center.dy - area.center.dy)
          .abs();

  group('CenteredStateMessage', () {
    testWidgets('in the very middle of the room it has', (tester) async {
      await pumpIn(
        tester,
        const CenteredStateMessage(
          icon: AppIcons.book,
          title: 'No homework yet',
          subtitle: 'Homework from the school shows here.',
        ),
      );

      expect(
        offCenter(tester, const Rect.fromLTWH(0, 0, 390, 600)),
        lessThan(1),
      );
    });

    testWidgets('below what lies over it: in the middle of the rest', (
      tester,
    ) async {
      await pumpIn(
        tester,
        const CenteredStateMessage(
          top: 100,
          icon: AppIcons.book,
          title: 'No messages yet',
        ),
      );

      // 100 to 600 is what shows.
      expect(
        offCenter(tester, const Rect.fromLTWH(0, 100, 390, 500)),
        lessThan(1),
      );
    });

    testWidgets('too little room: it scrolls, nothing overflows', (
      tester,
    ) async {
      await pumpIn(
        tester,
        const SizedBox(
          height: 120,
          child: CenteredStateMessage(
            icon: AppIcons.book,
            title: 'No homework yet',
            subtitle: 'Homework from the school shows here.',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Scrollable), findsOneWidget);
    });
  });

  testWidgets('StateMessage on its own: as before, room above it', (
    tester,
  ) async {
    await pumpIn(
      tester,
      const Align(
        alignment: Alignment.topCenter,
        child: StateMessage(icon: AppIcons.book, title: 'Done'),
      ),
    );

    expect(tester.getRect(find.byType(StateMessage)).top, 0);
    expect(tester.getTopLeft(find.byType(Column).first).dy, greaterThan(40));
  });
}
