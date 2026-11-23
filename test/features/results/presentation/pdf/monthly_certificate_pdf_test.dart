import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/features/results/presentation/pdf/monthly_certificate_pdf.dart';

import '../../results_fixtures.dart';

/// Whether [bytes] has [part] in it, as it is.
bool _contains(Uint8List bytes, Uint8List part) {
  for (var start = 0; start <= bytes.length - part.length; start++) {
    var match = true;
    for (var i = 0; i < part.length; i++) {
      if (bytes[start + i] != part[i]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}

/// A piece from the middle of the blank page [image]: the PDF has it as it
/// is, so it tells which page the certificate was written on.
Future<Uint8List> _pieceOf(String image) async {
  final bytes = (await rootBundle.load(image)).buffer.asUint8List();
  final middle = bytes.length ~/ 2;
  return Uint8List.sublistView(bytes, middle, middle + 64);
}

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

  group('the page it is written on', () {
    test('first to third primary: theirs, without Science, Social Studies '
        'and ICT', () {
      for (final grade in [
        'First Primary',
        'Second Primary',
        'third primary',
        'Grade 1',
        'Grade 3',
        'Primary 2',
        '2nd Primary',
        'الصف الأول الابتدائي',
        'الصف الثاني الابتدائى',
        'الثالث الابتدائي',
        'الصف ٢ الابتدائي',
      ]) {
        expect(
          MonthlyCertificatePdf.templateFor(grade),
          AppImages.monthlyCertificatePrimary,
          reason: grade,
        );
      }
    });

    test('fourth primary and up, KG, or no grade: the one with every '
        'subject', () {
      for (final grade in [
        'Fourth Primary',
        'Sixth Primary',
        'Grade 4',
        'Grade 12',
        'KG1',
        'KG 2',
        'الصف الرابع الابتدائي',
        'الصف الأول الإعدادي',
        '',
      ]) {
        expect(
          MonthlyCertificatePdf.templateFor(grade),
          AppImages.monthlyCertificate,
          reason: grade,
        );
      }
    });

    test('made for first primary: on the first-to-third page', () async {
      final file = await MonthlyCertificatePdf.build(certificate);

      expect(certificate.grade, 'First Primary');
      expect(
        _contains(
          file.bytes,
          await _pieceOf(AppImages.monthlyCertificatePrimary),
        ),
        isTrue,
      );
      expect(
        _contains(file.bytes, await _pieceOf(AppImages.monthlyCertificate)),
        isFalse,
      );
    });

    test('made without a grade: on the page with every subject', () async {
      final file = await MonthlyCertificatePdf.build(certificateWithoutStudent);

      expect(
        _contains(file.bytes, await _pieceOf(AppImages.monthlyCertificate)),
        isTrue,
      );
      expect(
        _contains(
          file.bytes,
          await _pieceOf(AppImages.monthlyCertificatePrimary),
        ),
        isFalse,
      );
    });
  });
}
