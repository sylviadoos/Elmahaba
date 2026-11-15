import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/certificate_download_button.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_details_view.dart';

import '../../../../helpers/test_app.dart';
import '../../results_fixtures.dart';

/// [certificate] with nothing published on it yet.
MonthlyCertificateEntity blank({
  bool withMonths = false,
  bool withSubjects = false,
}) => MonthlyCertificateEntity(
  studentName: certificate.studentName,
  studentNameAr: certificate.studentNameAr,
  grade: certificate.grade,
  className: certificate.className,
  academicYear: certificate.academicYear,
  months: withMonths ? certificate.months : const [],
  subjects: withSubjects ? certificate.subjects : const [],
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<void> pumpView(
    WidgetTester tester,
    MonthlyCertificateEntity? shown,
  ) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(
              child: ResultDetailsView(result: october, certificate: shown),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(TestApp(router: router));
    await tester.pumpAndSettle();
  }

  bool offersDownload(WidgetTester tester) =>
      find.byType(CertificateDownloadButton).evaluate().isNotEmpty;

  testWidgets('marks published: the certificate can be downloaded', (
    tester,
  ) async {
    await pumpView(tester, certificate);

    expect(offersDownload(tester), isTrue);
    expect(find.text(l10n.downloadCertificate), findsOneWidget);
  });

  testWidgets('nothing on it yet: no download, it would save blank', (
    tester,
  ) async {
    await pumpView(tester, blank());

    expect(offersDownload(tester), isFalse);
  });

  testWidgets('months but no subjects marked: still nothing to download', (
    tester,
  ) async {
    await pumpView(tester, blank(withMonths: true));

    expect(offersDownload(tester), isFalse);
  });

  testWidgets('subjects but no month published: nothing to download', (
    tester,
  ) async {
    await pumpView(tester, blank(withSubjects: true));

    expect(offersDownload(tester), isFalse);
  });

  testWidgets("a term's result: no certificate at all", (tester) async {
    await pumpView(tester, null);

    expect(offersDownload(tester), isFalse);
  });
}
