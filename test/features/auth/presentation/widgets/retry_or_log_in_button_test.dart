import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';

import '../../../../helpers/test_app.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    AppException exception, {
    VoidCallback? onRetry,
  }) => tester.pumpWidget(
    TestApp(
      router: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: RetryOrLogInButton(
                exception: exception,
                onRetry: onRetry ?? () {},
              ),
            ),
          ),
        ],
      ),
    ),
  );

  testWidgets('the session ended: "Log in", not "Try again"', (tester) async {
    await pump(tester, const UnauthorizedException());

    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('any other error: "Try again", which loads again', (
    tester,
  ) async {
    var retried = 0;
    await pump(tester, const NetworkException(), onRetry: () => retried++);

    await tester.tap(find.text('Try again'));
    expect(retried, 1);
    expect(find.text('Log in'), findsNothing);
  });
}
