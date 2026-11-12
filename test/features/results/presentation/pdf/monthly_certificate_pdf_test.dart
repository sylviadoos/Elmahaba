import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/results/presentation/pdf/monthly_certificate_pdf.dart';

import '../../results_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('makes a one-page PDF named for the year', () async {
    final file = await MonthlyCertificatePdf.build(certificate);

    expect(file.name, 'monthly-certificate-2026-2027.pdf');
    expect(ascii.decode(file.bytes.sublist(0, 5)), '%PDF-');
    // The certificate's own page, under the marks.
    expect(file.bytes.length, greaterThan(400000));
  });

  test('without a class, grade or name: still made', () async {
    final file = await MonthlyCertificatePdf.build(certificateWithoutStudent);

    expect(ascii.decode(file.bytes.sublist(0, 5)), '%PDF-');
  });
}
