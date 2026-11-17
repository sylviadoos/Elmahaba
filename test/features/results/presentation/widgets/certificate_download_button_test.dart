import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/results/presentation/pdf/certificate_pdf_file.dart';
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

  testWidgets('Preview opens the certificate before saving anything', (
    tester,
  ) async {
    final dialog = useFakeFilePicker();
    Object? opened;
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
        GoRoute(
          path: AppRoutes.certificatePreview,
          builder: (_, state) {
            opened = state.extra;
            return const Scaffold(body: Text('preview'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(TestApp(router: router));

    await tester.tap(find.text(en.preview));
    await tester.pumpAndSettle();

    expect(find.text('preview'), findsOneWidget);
    // The same PDF the download would save, so what's on screen is what
    // lands in Downloads.
    expect(opened, isA<CertificatePdfFile>());
    expect(
      ascii.decode((opened! as CertificatePdfFile).bytes.sublist(0, 5)),
      '%PDF-',
    );
    // Nothing saved by looking at it.
    expect(dialog.bytes, isNull);
  });

  /// Whether [label]'s button is the one turning.
  Finder spinnerOn(String label) => find.descendant(
    of: find.widgetWithText(OutlinedButton, label),
    matching: find.byType(CircularProgressIndicator),
  );

  testWidgets('only the button tapped turns: Preview', (tester) async {
    useFakeFilePicker();
    // The page and font slow to load, so the making is there to see.
    // Left in place after, at full speed: taking it away would take the
    // test's own assets with it.
    var slow = true;
    addTearDown(() => slow = false);
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async {
        if (slow) await Future<void>.delayed(const Duration(milliseconds: 200));
        final key = Uri.decodeFull(utf8.decode(message!.buffer.asUint8List()));
        return ByteData.sublistView(File(key).readAsBytesSync());
      },
    );
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
        GoRoute(
          path: AppRoutes.certificatePreview,
          builder: (_, _) => const Scaffold(body: Text('preview')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(TestApp(router: router));

    await tester.tap(find.text(en.preview));
    await tester.pump();

    expect(spinnerOn(en.preview), findsOneWidget);
    expect(spinnerOn(en.downloadCertificate), findsNothing);

    await tester.pumpAndSettle();
  });

  testWidgets('the preview taken away, not closed (a notification opened): the '
      'buttons work again', (tester) async {
    useFakeFilePicker();
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
        GoRoute(
          path: AppRoutes.certificatePreview,
          builder: (_, _) => const Scaffold(body: Text('preview')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(TestApp(router: router));
    await tester.tap(find.text(en.preview));
    await tester.pumpAndSettle();

    router.go('/');
    await tester.pumpAndSettle();

    expect(spinnerOn(en.preview), findsNothing);
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, en.preview),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('only the button tapped turns: Download', (tester) async {
    // Held open, so the turning is there to see.
    useFakeFilePicker(
      outcome: () async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return Uri.parse('content://downloads/certificate');
      },
    );
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
    // Past making the PDF, into the save dialog.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(spinnerOn(en.downloadCertificate), findsOneWidget);
    expect(spinnerOn(en.preview), findsNothing);

    await tester.pumpAndSettle();
  });

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
