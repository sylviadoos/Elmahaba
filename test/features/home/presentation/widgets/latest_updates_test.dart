import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/latest_updates_bloc.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/latest_updates_intent.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/latest_updates.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/stub_routes.dart';
import '../../../../helpers/test_app.dart';
import '../../home_fixtures.dart';
import '../../home_mocks.mocks.dart';

final en = lookupAppLocalizations(const Locale('en'));
final ar = lookupAppLocalizations(const Locale('ar'));

void main() {
  late MockGetLatestAnnouncementsUseCase getAnnouncements;
  late MockGetLatestHomeworkUseCase getHomework;
  late MockGetLatestResultsUseCase getResults;
  late Map<String, Object?> extras;

  setUpAll(() {
    provideResultDummy<LatestItemsEntity<AnnouncementEntity>>();
    provideResultDummy<LatestItemsEntity<HomeworkEntity>>();
    provideResultDummy<LatestItemsEntity<LatestResultEntity>>();
  });

  setUp(() {
    extras = {};
    getAnnouncements = MockGetLatestAnnouncementsUseCase();
    getHomework = MockGetLatestHomeworkUseCase();
    getResults = MockGetLatestResultsUseCase();
    when(getAnnouncements(any)).thenAnswer(
      (_) async => Success(data: latest([holiday, trip], unread: 1)),
    );
    when(
      getHomework(any),
    ).thenAnswer((_) async => Success(data: latest([mathSheet], unread: 1)));
    when(
      getResults(any),
    ).thenAnswer((_) async => Success(data: latest([termResult])));
  });

  /// Home's latest for child 1208 on a [size] phone in [locale].
  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Size size = const Size(390, 844),
  }) async {
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final bloc = LatestUpdatesBloc(getAnnouncements, getHomework, getResults)
      ..add(const ShowChildUpdatesIntent(1208));
    addTearDown(bloc.close);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: BlocProvider.value(
                value: bloc,
                child: const LatestUpdates(),
              ),
            ),
          ),
        ),
        ...stubRoutes([
          AppRoutes.chat,
          AppRoutes.homework,
          AppRoutes.results,
        ], extras: extras),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(TestApp(router: router, locale: locale));
    await tester.pump();
  }

  testWidgets('shows the newest of each, with how many are new', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text(en.announcements), findsOneWidget);
    expect(find.text(holiday.title), findsOneWidget);
    expect(find.text(holiday.body), findsOneWidget);
    expect(find.text(trip.title), findsOneWidget);
    expect(find.text(en.homework), findsOneWidget);
    expect(find.text(mathSheet.title), findsOneWidget);
    expect(find.text('Math'), findsOneWidget);
    expect(find.text(en.results), findsOneWidget);
    expect(find.text(termResult.title), findsOneWidget);
    // Announcements and homework each have one the parent hasn't seen.
    expect(find.text(en.newCount(1)), findsNWidgets(2));
    expect(find.text(en.seeAll), findsNWidgets(3));
  });

  testWidgets('says when there are none yet', (tester) async {
    when(
      getHomework(any),
    ).thenAnswer((_) async => Success(data: latest(<HomeworkEntity>[])));

    await pump(tester);

    expect(find.text(en.noHomework), findsOneWidget);
    expect(find.text(holiday.title), findsOneWidget);
  });

  testWidgets('"Try again" loads again what failed', (tester) async {
    var calls = 0;
    when(getResults(any)).thenAnswer(
      (_) async => calls++ == 0
          ? const Failure(exception: UnknownException())
          : Success(data: latest([termResult])),
    );

    await pump(tester);
    expect(find.text(termResult.title), findsNothing);

    await tester.tap(find.text(en.tryAgain));
    await tester.pump();
    await tester.pump();

    expect(find.text(en.tryAgain), findsNothing);
    expect(find.text(termResult.title), findsOneWidget);
  });

  testWidgets('opens the chat, the child\'s homework and the results', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text(holiday.title));
    await tester.pumpAndSettle();
    expect(find.text(AppRoutes.chat), findsOneWidget);

    await pump(tester);
    await tester.tap(find.text(mathSheet.title));
    await tester.pumpAndSettle();
    expect(find.text(AppRoutes.homework), findsOneWidget);
    expect(extras[AppRoutes.homework], 1208);

    await pump(tester);
    await tester.ensureVisible(find.text(termResult.title));
    await tester.tap(find.text(termResult.title));
    await tester.pumpAndSettle();
    expect(find.text(AppRoutes.results), findsOneWidget);
  });

  testWidgets('fits a small phone in Arabic', (tester) async {
    await pump(tester, locale: const Locale('ar'), size: const Size(320, 568));

    expect(tester.takeException(), isNull);
    expect(find.text(ar.announcements), findsOneWidget);
    expect(find.text(ar.newCount(1)), findsNWidgets(2));
  });
}
