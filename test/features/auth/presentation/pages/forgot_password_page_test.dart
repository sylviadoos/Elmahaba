import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/forgot_password_page.dart';

import '../../../../helpers/form_helpers.dart';
import '../../auth_fixtures.dart';
import 'auth_page_harness.dart';

void main() {
  late AuthPageHarness harness;

  setUp(() => (harness = AuthPageHarness()).register());
  tearDown(getIt.reset);

  testWidgets('Send code waits for a whole Egyptian mobile', (tester) async {
    await harness.pump(
      tester,
      AppRoutes.forgotPassword,
      const ForgotPasswordPage(),
    );
    expect(tester.isEnabled(l10n.sendCode), isFalse);

    await tester.enterText(textFieldLabeled(l10n.mobileNumber), '0101234567');
    await tester.pump();
    expect(tester.isEnabled(l10n.sendCode), isFalse);

    await tester.enterText(textFieldLabeled(l10n.mobileNumber), phone);
    await tester.pump();
    expect(tester.isEnabled(l10n.sendCode), isTrue);
  });

  testWidgets('Send code opens the code page for the number', (tester) async {
    await harness.pump(
      tester,
      AppRoutes.forgotPassword,
      const ForgotPasswordPage(),
    );
    await tester.enterText(textFieldLabeled(l10n.mobileNumber), phone);
    await tester.pump();
    await tester.tapShown(buttonLabeled(l10n.sendCode));
    await tester.settle();

    expect(find.text(AppRoutes.resetCode), findsOneWidget);
    expect(harness.extras[AppRoutes.resetCode], phone);
  });

  testWidgets('Log in goes back to Log in', (tester) async {
    await harness.pump(
      tester,
      AppRoutes.forgotPassword,
      const ForgotPasswordPage(),
    );
    await tester.tapShown(buttonLabeled(l10n.login));
    await tester.settle();

    expect(find.text(AppRoutes.login), findsOneWidget);
  });
}
