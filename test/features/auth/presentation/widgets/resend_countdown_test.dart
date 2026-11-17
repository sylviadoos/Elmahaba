import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/features/auth/presentation/widgets/resend_countdown.dart';

import '../../../../helpers/test_app.dart';

void main() {
  Future<void> pump(WidgetTester tester, int seconds) => tester.pumpWidget(
    TestApp(
      router: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                Scaffold(body: ResendCountdown(seconds: seconds)),
          ),
        ],
      ),
    ),
  );

  for (final (seconds, time) in [(45, '0:45'), (60, '1:00'), (5, '0:05')]) {
    testWidgets('$seconds seconds: "$time"', (tester) async {
      await pump(tester, seconds);

      expect(find.textContaining(time, findRichText: true), findsOneWidget);
    });
  }
}
