import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/pdf/certificate_pdf_file.dart';

/// The school's monthly examination certificate: its own blank page
/// ([AppImages.monthlyCertificate]) with the student written on its lines
/// and each mark in its box — by subject, month (October, November, March,
/// April) and part (monthly exam, homework…). What the page has no box for
/// (another subject or month) isn't written; the app shows all of it.
abstract final class MonthlyCertificatePdf {
  static Future<CertificatePdfFile> build(
    MonthlyCertificateEntity certificate,
  ) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Bold.ttf'),
    );
    final background = pw.MemoryImage(
      (await rootBundle.load(
        AppImages.monthlyCertificate,
      )).buffer.asUint8List(),
    );

    final document = pw.Document(
      title: 'Monthly examination certificate',
      author: 'Al Mahabbah Schools',
    );
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape.copyWith(
          marginLeft: 0,
          marginTop: 0,
          marginRight: 0,
          marginBottom: 0,
        ),
        build: (context) => pw.Stack(
          children: [
            pw.Image(
              background,
              width: _pageWidth,
              height: _pageHeight,
              fit: pw.BoxFit.fill,
            ),
            ..._student(certificate, font),
            ..._marks(certificate, font),
          ],
        ),
      ),
    );

    // "2026-2027", or "2026/2027" as a child's year is written.
    final year = certificate.academicYear
        .replaceAll('/', '-')
        .replaceAll(RegExp(r'[^0-9-]'), '');
    return CertificatePdfFile(
      name: year.isEmpty
          ? 'monthly-certificate.pdf'
          : 'monthly-certificate-$year.pdf',
      bytes: await document.save(),
    );
  }

  // The page is A4 landscape; the blank certificate is 1491 × 1055 px, and
  // everything below is measured on it.
  static final double _pageWidth = PdfPageFormat.a4.landscape.width;
  static final double _pageHeight = PdfPageFormat.a4.landscape.height;
  static const double _imageWidth = 1491;
  static const double _imageHeight = 1055;

  static const _ink = PdfColor.fromInt(0xFF1E2C8C);

  /// Each subject's four month columns, by their lines' x.
  static const _subjectColumns = <String, List<double>>{
    'arabic': [205, 236.5, 270.5, 303.5, 334],
    'math': [337, 370.5, 403.5, 437.5, 469],
    'englishol': [472, 504.5, 538.5, 573.5, 606],
    'englishal': [609, 641.5, 675.5, 710.5, 743],
    'german': [746, 777.5, 810.5, 844.5, 876],
    'science': [880, 913.5, 947.5, 980.5, 1012],
    'socialstudies': [1015, 1048.5, 1082.5, 1116.5, 1149],
    'religion': [1153, 1190.5, 1232.5, 1271.5, 1309],
    'ict': [1312, 1347.5, 1384, 1426.5, 1465],
  };

  /// Other names the school may give them.
  static const _subjectAliases = {
    'english': 'englishol',
    'englishlanguage': 'englishol',
    'mathematics': 'math',
    'maths': 'math',
    'socialstudy': 'socialstudies',
    'social': 'socialstudies',
    'religious': 'religion',
    'religiouseducation': 'religion',
    'computer': 'ict',
  };

  /// The month columns, left to right in each subject.
  static const _monthColumns = ['october', 'november', 'march', 'april'];

  /// Each part's row, by its lines' y.
  static const _componentRows = <String, (double, double)>{
    'monthlyexam': (510, 555),
    'homework': (555, 604.5),
    'classwork': (604.5, 653),
    'weeklyassessment': (653, 704),
    'attendanceandbehavior': (704, 757),
  };

  /// "Attendance & behavior" → "attendanceandbehavior", so the school's
  /// names match the page's however they're written.
  static String _key(String name) => name
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp('[^a-z0-9]'), '');

  /// The name, class and grade on their lines; a line the school left
  /// empty stays blank.
  static List<pw.Widget> _student(
    MonthlyCertificateEntity certificate,
    pw.Font font,
  ) {
    final english = certificate.studentName.trim();
    final name = english.isNotEmpty
        ? english
        : certificate.studentNameAr.trim();
    final className = certificate.className.trim();
    // "First Primary": the page says "grade ___ of primary school".
    final grade = certificate.grade
        .replaceAll(RegExp(r'\s*primary\s*', caseSensitive: false), ' ')
        .trim();
    return [
      if (name.isNotEmpty)
        _text(
          name,
          font,
          left: 480,
          top: 162,
          right: 905,
          bottom: 198,
          size: 13,
          alignment: pw.Alignment.bottomLeft,
        ),
      if (className.isNotEmpty)
        _text(
          className,
          font,
          left: 1030,
          top: 154,
          right: 1170,
          bottom: 189,
          size: 13,
          alignment: pw.Alignment.bottomCenter,
        ),
      if (grade.isNotEmpty)
        _text(
          grade,
          font,
          left: 912,
          top: 226,
          right: 1002,
          bottom: 258,
          size: 11,
          alignment: pw.Alignment.bottomCenter,
        ),
    ];
  }

  /// Each mark in its box.
  static List<pw.Widget> _marks(
    MonthlyCertificateEntity certificate,
    pw.Font font,
  ) {
    final monthKeys = {
      for (final month in certificate.months) _key(month.month): month.key,
    };
    final boxes = <pw.Widget>[];
    for (final subject in certificate.subjects) {
      final name = _key(subject.name);
      final columns = _subjectColumns[_subjectAliases[name] ?? name];
      if (columns == null) continue;
      for (final (column, month) in _monthColumns.indexed) {
        final marks = subject.marks[monthKeys[month]];
        if (marks == null) continue;
        for (final MapEntry(key: part, value: mark)
            in marks.components.entries) {
          final row = _componentRows[_key(part)];
          if (row == null) continue;
          boxes.add(
            _text(
              _number(mark),
              font,
              left: columns[column],
              top: row.$1,
              right: columns[column + 1],
              bottom: row.$2,
              size: 10,
            ),
          );
        }
      }
    }
    return boxes;
  }

  /// "14", "9.5".
  static String _number(double mark) => mark == mark.roundToDouble()
      ? mark.toInt().toString()
      : mark.toStringAsFixed(1);

  /// [text] in the box measured on the blank page, from ([left], [top]) to
  /// ([right], [bottom]) in its pixels. Never empty: the pdf package can't
  /// fit an empty text in a box, and the whole certificate fails.
  static pw.Widget _text(
    String text,
    pw.Font font, {
    required double left,
    required double top,
    required double right,
    required double bottom,
    required double size,
    pw.Alignment alignment = pw.Alignment.center,
  }) {
    final scaleX = _pageWidth / _imageWidth;
    final scaleY = _pageHeight / _imageHeight;
    return pw.Positioned(
      left: left * scaleX,
      top: top * scaleY,
      child: pw.SizedBox(
        width: (right - left) * scaleX,
        height: (bottom - top) * scaleY,
        child: pw.Align(
          alignment: alignment,
          child: pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            child: pw.Text(
              text,
              textDirection: Bidi.detectRtlDirectionality(text)
                  ? pw.TextDirection.rtl
                  : pw.TextDirection.ltr,
              style: pw.TextStyle(font: font, fontSize: size, color: _ink),
            ),
          ),
        ),
      ),
    );
  }
}
