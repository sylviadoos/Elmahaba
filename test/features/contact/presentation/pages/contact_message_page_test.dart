import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations_en.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_bloc.dart';
import 'package:al_mahhaba_school/features/auth/data/models/parent_model.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/contact/domain/use_cases/send_contact_message_use_case.dart';
import 'package:al_mahhaba_school/features/contact/presentation/pages/contact_message_page.dart';
import 'package:al_mahhaba_school/features/contact/presentation/view_model/contact_message_view_model.dart';

import '../../../../helpers/form_helpers.dart';
import '../../../../helpers/test_app.dart';
import '../../../app_status/app_status_mocks.mocks.dart';
import '../../../auth/auth_fixtures.dart';
import '../../../auth/auth_mocks.mocks.dart';
import 'contact_message_page_test.mocks.dart';

final l10n = AppLocalizationsEn();

@GenerateNiceMocks([MockSpec<SendContactMessageUseCase>()])
void main() {
  late MockGetSavedParentUseCase getSavedParent;

  setUp(() {
    getSavedParent = MockGetSavedParentUseCase();
    getIt.registerFactory<ContactMessageViewModel>(
      () => ContactMessageViewModel(MockSendContactMessageUseCase()),
    );
  });

  tearDown(getIt.reset);

  /// Opens Send message with the parent kept on the phone as [savedJson]
  /// (none: a visitor), shown as at launch.
  Future<void> pump(
    WidgetTester tester, {
    Map<String, dynamic>? savedJson,
  }) async {
    tester.usePhoneScreen();
    when(getSavedParent()).thenAnswer(
      (_) async => savedJson == null ? null : ParentModel.fromJson(savedJson),
    );
    final parentViewModel = ParentViewModel(getSavedParent);
    addTearDown(parentViewModel.close);
    await parentViewModel.doAction(const ShowSavedParentEvent());

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const ContactMessagePage()),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TestApp(
        router: router,
        providers: [
          BlocProvider<ParentViewModel>.value(value: parentViewModel),
          // Whether "Log in" shows doesn't matter here.
          BlocProvider<AppStatusBloc>(
            create: (_) => AppStatusBloc(MockGetAppStatusUseCase()),
          ),
        ],
      ),
    );
    await tester.pump();
  }

  String textOf(WidgetTester tester, String label) =>
      tester.widget<TextField>(textFieldLabeled(label)).controller!.text;

  testWidgets('signed in: their name and the number they logged in with', (
    tester,
  ) async {
    // As log in keeps them.
    await pump(tester, savedJson: {...parentJson, 'full_phone': phone});

    expect(textOf(tester, l10n.firstName), 'Mina');
    expect(textOf(tester, l10n.lastName), 'Nagy');
    expect(textOf(tester, l10n.mobileNumber), '1012345678');
    expect(textOf(tester, l10n.email), '');
  });

  testWidgets('kept before the full number was: the name only', (tester) async {
    await pump(tester, savedJson: parentJson);

    expect(textOf(tester, l10n.firstName), 'Mina');
    expect(textOf(tester, l10n.mobileNumber), '');
  });

  testWidgets('a visitor: all empty', (tester) async {
    await pump(tester);

    expect(textOf(tester, l10n.firstName), '');
    expect(textOf(tester, l10n.lastName), '');
    expect(textOf(tester, l10n.mobileNumber), '');
  });
}
