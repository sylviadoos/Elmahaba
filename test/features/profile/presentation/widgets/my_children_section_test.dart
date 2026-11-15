import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/my_children_section.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/profile_child_row.dart';

import '../../../../helpers/test_app.dart';
import 'my_children_section_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ChildrenViewModel>()])
const _omar = ChildEntity(
  studentId: 1208,
  name: 'Omar Hany',
  nameAr: 'عمر هاني',
  nationalId: '••••2341',
  relationship: 'father',
  access: 'active',
  grade: 'Fourth Primary',
  className: '4B',
  academicYear: '2026/2027',
);

const _lina = ChildEntity(
  studentId: 1209,
  name: 'Lina Hany',
  nameAr: 'لينا هاني',
  nationalId: '••••7781',
  relationship: 'father',
  access: 'active',
  grade: 'KG2',
  className: 'A',
  academicYear: '2026/2027',
);

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  late MockChildrenViewModel childrenViewModel;

  setUp(() {
    childrenViewModel = MockChildrenViewModel();
    when(childrenViewModel.stream).thenAnswer((_) => const Stream.empty());
  });

  /// The section as Settings shows it, for [children] on the account.
  Future<String?> pumpSection(
    WidgetTester tester,
    List<ChildEntity> children,
  ) async {
    tester.usePhoneScreen();
    when(
      childrenViewModel.state,
    ).thenReturn(ChildrenState(children: BaseState.success(children)));
    String? opened;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: SingleChildScrollView(child: MyChildrenSection()),
          ),
        ),
        GoRoute(
          path: AppRoutes.childDetails,
          builder: (_, state) {
            opened = state.pathParameters['id'];
            return const Scaffold(body: Text('child'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TestApp(
        router: router,
        providers: [
          BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return opened;
  }

  testWidgets('every child on the account, without opening the profile', (
    tester,
  ) async {
    await pumpSection(tester, const [_omar, _lina]);

    expect(find.text(en.myChildren), findsOneWidget);
    expect(find.byType(ProfileChildRow), findsNWidgets(2));
    expect(find.text('Omar Hany'), findsOneWidget);
    expect(find.text('Lina Hany'), findsOneWidget);
  });

  testWidgets('tapping one opens their details', (tester) async {
    await pumpSection(tester, const [_omar, _lina]);

    await tester.tap(find.text('Lina Hany'));
    await tester.pumpAndSettle();

    expect(find.text('child'), findsOneWidget);
  });

  testWidgets('no children yet: the heading and "Add a child" only', (
    tester,
  ) async {
    await pumpSection(tester, const []);

    expect(find.text(en.myChildren), findsOneWidget);
    expect(find.byType(ProfileChildRow), findsNothing);
    expect(find.text(en.addAChild), findsOneWidget);
  });
}
