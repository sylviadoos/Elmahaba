import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/certificate_download_button.dart';

import '../../../../helpers/fake_file_picker.dart';
import '../../../../helpers/test_app.dart';
import '../../results_fixtures.dart';

final en = lookupAppLocalizations(const Locale('en'));

void main() {
  /// Taps "Download certificate (PDF)" for [certificate], the dialog ending
  /// in [outcome]: saved, unless said otherwise.
  Future<FakeFilePicker> download(
    WidgetTester tester,
    MonthlyCertificateEntity certificate, {
    Future<Uri?> Function()? outcome,
  }) async {
    final dialog = useFakeFilePicker(outcome: outcome);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Center(
              child: CertificateDownloadButton(certificate: certificate),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(TestApp(router: router));
    await tester.tap(find.text(en.downloadCertificate));
    await tester.pumpAndSettle();
    return dialog;
  }

  testWidgets('saves the certificate as a PDF, and says so', (tester) async {
    final dialog = await download(tester, certificate);

    expect(dialog.fileName, 'monthly-certificate-2026-2027.pdf');
    expect(dialog.mimeType, 'application/pdf');
    expect(ascii.decode(dialog.bytes!.sublist(0, 5)), '%PDF-');
    expect(find.text(en.certificateSaved), findsOneWidget);
  });

  testWidgets('without a class, grade or name: still saves it', (tester) async {
    final dialog = await download(tester, certificateWithoutStudent);

    expect(ascii.decode(dialog.bytes!.sublist(0, 5)), '%PDF-');
    expect(find.text(en.certificateSaved), findsOneWidget);
  });

  testWidgets('can\'t save it there: says so', (tester) async {
    await download(
      tester,
      certificate,
      outcome: () async => throw PlatformException(code: 'save_failed'),
    );

    expect(find.text(en.certificateNotSaved), findsOneWidget);
  });
}
