import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/change_password_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';

import '../../../../helpers/form_helpers.dart';
import '../../auth_fixtures.dart';
import 'auth_page_harness.dart';

void main() {
  late AuthPageHarness harness;

  setUp(() => (harness = AuthPageHarness()).register());
  tearDown(getIt.reset);

  const page = ChangePasswordPage();

  Future<void> type(
    WidgetTester tester, {
    String current = 'old-pass1',
    String pass = password,
  }) async {
    await tester.enterText(textFieldLabeled(l10n.currentPassword), current);
    await tester.enterText(textFieldLabeled(l10n.newPassword), pass);
    await tester.enterText(textFieldLabeled(l10n.confirmNewPassword), pass);
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tapShown(buttonLabeled(l10n.saveNewPassword));
    await tester.settle();
  }

  group('Save waits for', () {
    testWidgets('the current password', (tester) async {
      await harness.pump(tester, AppRoutes.changePassword, page);
      await type(tester, current: '');

      expect(tester.isEnabled(l10n.saveNewPassword), isFalse);
    });

    testWidgets('a new password unlike the current one', (tester) async {
      await harness.pump(tester, AppRoutes.changePassword, page);
      await type(tester, current: password);

      expect(tester.isEnabled(l10n.saveNewPassword), isFalse);
    });

    testWidgets('then it can save', (tester) async {
      await harness.pump(tester, AppRoutes.changePassword, page);
      await type(tester);

      expect(tester.isEnabled(l10n.saveNewPassword), isTrue);
    });
  });

  testWidgets('changed: Password updated, then back to Settings', (
    tester,
  ) async {
    when(
      harness.changePassword(any),
    ).thenAnswer((_) async => const Success(data: null));
    await harness.pump(tester, AppRoutes.changePassword, page);
    await type(tester);
    await save(tester);

    verify(harness.changePassword(changeRequest)).called(1);
    expect(find.text(l10n.passwordUpdated), findsOneWidget);

    await tester.tapShown(buttonLabeled(l10n.backToSettings));
    await tester.settle();
    expect(find.text(AppRoutes.settings), findsOneWidget);
  });

  testWidgets('a wrong current password: its message under it', (tester) async {
    when(harness.changePassword(any)).thenAnswer(
      (_) async => const Failure(
        exception: ServerException(
          code: AuthErrorCodes.currentPasswordIncorrect,
          message: 'The current password is wrong.',
        ),
      ),
    );
    await harness.pump(tester, AppRoutes.changePassword, page);
    await type(tester);
    await save(tester);

    expect(find.text('The current password is wrong.'), findsOneWidget);
    expect(find.text(l10n.checkHighlightedFields), findsOneWidget);
  });

  testWidgets('signed out meanwhile: logs out, opens Log in', (tester) async {
    when(harness.changePassword(any)).thenAnswer(
      (_) async => const Failure(exception: UnauthorizedException()),
    );
    when(harness.logout()).thenAnswer((_) async => const Success(data: null));
    await harness.pump(tester, AppRoutes.changePassword, page);
    await type(tester);
    await save(tester);

    verify(harness.logout()).called(1);
    verify(
      harness.parentViewModel.doAction(argThat(isA<ClearParentEvent>())),
    ).called(1);
    verify(
      harness.childrenViewModel.doAction(argThat(isA<ClearChildrenEvent>())),
    ).called(1);
    expect(find.text(l10n.expiredToken), findsOneWidget);
    expect(find.text(AppRoutes.login), findsOneWidget);
  });

  testWidgets('Forgot your current password? opens Forgot password', (
    tester,
  ) async {
    await harness.pump(tester, AppRoutes.changePassword, page);
    await tester.tapShown(buttonLabeled(l10n.forgotCurrentPassword));
    await tester.settle();

    expect(find.text(AppRoutes.forgotPassword), findsOneWidget);
  });
}
