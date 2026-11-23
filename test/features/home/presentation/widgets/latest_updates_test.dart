import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/announcement_args.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/latest_updates.dart';
import 'package:al_mahhaba_school/features/results/presentation/results_args.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/presentation/homework_args.dart';

import '../../../../helpers/stub_routes.dart';
import '../../../../helpers/test_app.dart';
import '../../home_fixtures.dart';

final en = lookupAppLocalizations(const Locale('en'));
final ar = lookupAppLocalizations(const Locale('ar'));

void main() {
  late Map<String, Object?> extras;

  setUp(() => extras = {});

  /// Home's latest for child 1208, from [dashboard], on a [size] phone in
  /// [locale].
  Future<void> pump(
    WidgetTester tester, {
    ChildDashboardEntity? dashboard,
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
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: LatestUpdates(
                dashboard: dashboard ?? dashboardWith(),
                childId: 1208,
              ),
            ),
          ),
        ),
        ...stubRoutes([
          AppRoutes.announcements,
          AppRoutes.announcementDetailsOf(holiday.id),
          AppRoutes.homework,
          AppRoutes.homeworkDetailsOf(mathSheet.id),
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
    await pump(tester, dashboard: dashboardWith(homework: <HomeworkEntity>[]));

    expect(find.text(en.noHomework), findsOneWidget);
    expect(find.text(holiday.title), findsOneWidget);
  });

  testWidgets('opens the announcement tapped, the homework, and the '
      'results', (tester) async {
    await pump(tester);

    // The announcement itself, not the list: Home already has it.
    await tester.tap(find.text(holiday.title));
    await tester.pumpAndSettle();
    final opened = AppRoutes.announcementDetailsOf(holiday.id);
    expect(find.text(opened), findsOneWidget);
    expect(
      extras[opened],
      isA<AnnouncementArgs>()
          .having((args) => args.announcement, 'announcement', holiday)
          .having((args) => args.studentId, 'studentId', 1208),
    );

    await pump(tester);
    await tester.tap(find.text(en.seeAll).first);
    await tester.pumpAndSettle();
    expect(find.text(AppRoutes.announcements), findsOneWidget);

    // The homework itself too, not the list.
    await pump(tester);
    await tester.tap(find.text(mathSheet.title));
    await tester.pumpAndSettle();
    final homework = AppRoutes.homeworkDetailsOf(mathSheet.id);
    expect(find.text(homework), findsOneWidget);
    expect(
      extras[homework],
      isA<HomeworkArgs>()
          .having((args) => args.homework, 'homework', mathSheet)
          .having((args) => args.studentId, 'studentId', 1208),
    );

    // "See all" on homework: the list.
    await pump(tester);
    await tester.tap(find.text(en.seeAll).at(1));
    await tester.pumpAndSettle();
    expect(find.text(AppRoutes.homework), findsOneWidget);
    expect(extras[AppRoutes.homework], 1208);

    await pump(tester);
    await tester.ensureVisible(find.text(termResult.title));
    await tester.tap(find.text(termResult.title));
    await tester.pumpAndSettle();
    expect(find.text(AppRoutes.results), findsOneWidget);
    // That result, not the newest.
    final result = extras[AppRoutes.results]! as ResultsArgs;
    expect(result.resultId, termResult.id);
    expect(result.title, termResult.title);
    expect(result.academicYear, termResult.academicYear);
  });

  testWidgets('fits a small phone in Arabic', (tester) async {
    await pump(tester, locale: const Locale('ar'), size: const Size(320, 568));

    expect(tester.takeException(), isNull);
    expect(find.text(ar.announcements), findsOneWidget);
    expect(find.text(ar.newCount(1)), findsNWidgets(2));
  });
}
