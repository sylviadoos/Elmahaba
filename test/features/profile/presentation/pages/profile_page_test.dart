import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_parent_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/profile_entity.dart';
import 'package:al_mahhaba_school/features/profile/presentation/pages/profile_page.dart';
import 'package:al_mahhaba_school/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/profile_child_row.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../../auth/auth_mocks.mocks.dart';
import '../../profile_mocks.mocks.dart';

final en = lookupAppLocalizations(const Locale('en'));
final ar = lookupAppLocalizations(const Locale('ar'));

const father = ChildParentEntity(
  name: 'Hany Adel',
  nameAr: 'هاني عادل',
  job: 'Engineer',
  education: 'Bachelor',
  phone: '0101****222',
);

const mother = ChildParentEntity(
  name: 'Mona Samir',
  nameAr: 'منى سمير',
  education: 'Master',
  phone: '0111****333',
);

const profile = ProfileEntity(
  name: 'Hany Adel',
  phone: '0101****222',
  language: 'en',
  father: father,
  mother: mother,
);

const omar = ChildEntity(
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

const lina = ChildEntity(
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
  late MockGetProfileUseCase getProfile;
  late MockParentViewModel parentViewModel;
  late MockChildrenViewModel childrenViewModel;

  setUp(() {
    getProfile = MockGetProfileUseCase();
    parentViewModel = MockParentViewModel();
    childrenViewModel = MockChildrenViewModel();
    provideResultDummy<ProfileEntity>();
    getIt.registerFactory<ProfileViewModel>(
      () => ProfileViewModel(
        getProfile,
        MockUpdateLanguageUseCase(),
        MockDeleteAccountUseCase(),
        MockGetNotificationPreferencesUseCase(),
        MockUpdateNotificationPreferencesUseCase(),
      ),
    );
    when(parentViewModel.stream).thenAnswer((_) => const Stream.empty());
    when(parentViewModel.state).thenReturn(
      const BaseState.success(
        ParentEntity(
          id: 7,
          name: 'Hany Adel',
          phone: '0101****222',
          language: 'en',
        ),
      ),
    );
    when(childrenViewModel.stream).thenAnswer((_) => const Stream.empty());
    when(childrenViewModel.state).thenReturn(
      const ChildrenState(children: BaseState.success([omar, lina])),
    );
    when(getProfile()).thenAnswer((_) async => const Success(data: profile));
  });

  tearDown(() => getIt.reset());

  /// Opens the profile from Settings, which had [fromSettings], on a
  /// [size] phone in [locale].
  Future<void> pump(
    WidgetTester tester, {
    ProfileEntity? fromSettings,
    Locale locale = const Locale('en'),
    Size size = const Size(390, 844),
  }) async {
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => ProfilePage(profile: fromSettings),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TestApp(
        router: router,
        locale: locale,
        providers: [
          BlocProvider<ParentViewModel>.value(value: parentViewModel),
          BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
        ],
      ),
    );
    await tester.pump();
  }

  testWidgets('loads the profile and shows the father, mother and children', (
    tester,
  ) async {
    await pump(tester);

    verify(getProfile()).called(1);
    // The father is the parent signed in: same phone.
    expect(find.textContaining(en.father.toUpperCase()), findsOneWidget);
    expect(find.textContaining(en.you.toUpperCase()), findsOneWidget);
    expect(find.text('Engineer'), findsOneWidget);
    expect(find.text('Bachelor'), findsOneWidget);
    expect(find.text(en.mother.toUpperCase()), findsOneWidget);
    expect(find.text('Mona Samir'), findsOneWidget);
    expect(find.text('Master'), findsOneWidget);
    expect(find.text('0111****333'), findsOneWidget);
    // The mother has no job: no line for it in her section.
    expect(find.text(en.job), findsOneWidget);
    expect(find.byType(ProfileChildRow), findsNWidgets(2));
  });

  testWidgets('shows what Settings had while the profile loads again', (
    tester,
  ) async {
    final reply = Completer<Result<ProfileEntity>>();
    when(getProfile()).thenAnswer((_) => reply.future);

    await pump(tester, fromSettings: profile);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Engineer'), findsOneWidget);

    reply.complete(const Success(data: profile));
    await tester.pump();
  });

  testWidgets('waits for the profile with nothing from Settings', (
    tester,
  ) async {
    final reply = Completer<Result<ProfileEntity>>();
    when(getProfile()).thenAnswer((_) => reply.future);

    await pump(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(en.father.toUpperCase()), findsNothing);
    expect(find.byType(ProfileChildRow), findsNWidgets(2));

    reply.complete(const Success(data: profile));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Engineer'), findsOneWidget);
  });

  testWidgets('leaves out a parent the school has nothing of', (tester) async {
    when(getProfile()).thenAnswer(
      (_) async => const Success(
        data: ProfileEntity(
          name: 'Hany Adel',
          phone: '0101****222',
          language: 'en',
          father: father,
          mother: ChildParentEntity(name: '', nameAr: ''),
        ),
      ),
    );

    await pump(tester);

    expect(find.text(en.mother.toUpperCase()), findsNothing);
    expect(find.textContaining(en.father.toUpperCase()), findsOneWidget);
  });

  testWidgets('still shows the children when the profile fails', (
    tester,
  ) async {
    when(
      getProfile(),
    ).thenAnswer((_) async => Failure(exception: NetworkException()));

    await pump(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Hany Adel'), findsOneWidget);
    expect(find.byType(ProfileChildRow), findsNWidgets(2));
  });

  testWidgets('fits a small phone in Arabic', (tester) async {
    await pump(tester, locale: const Locale('ar'), size: const Size(320, 568));

    expect(tester.takeException(), isNull);
    expect(find.textContaining(ar.father), findsOneWidget);
    // The header too names the father who signed in in Arabic.
    expect(find.text('هاني عادل'), findsNWidgets(2));
    expect(find.text('Hany Adel'), findsNothing);
    expect(find.text('منى سمير'), findsOneWidget);
  });
}
