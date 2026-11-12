import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/pages/add_children_page.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

import '../../../../helpers/test_app.dart';
import 'add_children_page_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ChildrenViewModel>()])
const _rovanio = ChildEntity(
  studentId: 9,
  name: 'Rovanio Abram',
  nameAr: 'روفانيو ابرام',
  nationalId: '••••0509',
  relationship: 'father',
  access: 'active',
  grade: 'Second Primary',
  className: 'A',
  academicYear: '2026/2027',
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  late MockChildrenViewModel childrenViewModel;

  /// What the page sees: the children on the account, nothing linking.
  void showing(List<ChildEntity> children) {
    when(
      childrenViewModel.state,
    ).thenReturn(ChildrenState(children: BaseState.success(children)));
    when(childrenViewModel.stream).thenAnswer((_) => const Stream.empty());
  }

  setUp(() {
    childrenViewModel = MockChildrenViewModel();
    showing(const [_rovanio]);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => BlocProvider<ChildrenViewModel>.value(
            value: childrenViewModel,
            child: const AddChildrenPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(TestApp(router: router));
    await tester.pumpAndSettle();
  }

  /// Continue, which leaves for Home.
  bool continueIsOn(WidgetTester tester) =>
      tester
          .widget<AppButton>(
            find.widgetWithText(AppButton, l10n.continueButton),
          )
          .onPressed !=
      null;

  Future<void> typeId(WidgetTester tester, String id) async {
    await tester.enterText(find.byType(TextField).first, id);
    await tester.pumpAndSettle();
  }

  testWidgets('a child on the account and nothing typed: Continue is on', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(continueIsOn(tester), isTrue);
  });

  testWidgets('an ID typed but not added: Continue waits for Add', (
    tester,
  ) async {
    await pumpPage(tester);

    await typeId(tester, '32207262500509');

    expect(continueIsOn(tester), isFalse);
  });

  testWidgets('half an ID blocks it too: it would be lost all the same', (
    tester,
  ) async {
    await pumpPage(tester);

    await typeId(tester, '3220');

    expect(continueIsOn(tester), isFalse);
  });

  testWidgets('the field cleared again: Continue comes back', (tester) async {
    await pumpPage(tester);
    await typeId(tester, '32207262500509');

    await typeId(tester, '');

    expect(continueIsOn(tester), isTrue);
  });

  testWidgets('no child on the account: Continue stays off', (tester) async {
    showing(const []);
    await pumpPage(tester);

    expect(continueIsOn(tester), isFalse);
  });

  testWidgets('Continue opens Home', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(AppButton, l10n.continueButton));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('the page asks for the children as it opens', (tester) async {
    await pumpPage(tester);

    verify(
      childrenViewModel.doAction(argThat(isA<LoadChildrenEvent>())),
    ).called(1);
  });
}
