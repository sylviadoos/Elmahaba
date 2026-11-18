import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_installment_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/installment_status.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pdf/fee_statement_pdf_file.dart';

/// The school's official fee statement, laid out like the one its system
/// prints: the student, then every fee (no [installments]) or the
/// installments being paid, the totals, and the settlement notice (always
/// with installments; on every fee, when some are being settled). Its labels are in English like the school's; names stay
/// as the school wrote them.
abstract final class FeeStatementPdf {
  static Future<FeeStatementPdfFile> build(
    FeeStatementEntity statement, {
    List<FeeInstallmentEntity>? installments,
    DateTime? date,
  }) async {
    // Montserrat like the school's statement; Cairo for the Arabic names.
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Montserrat-Medium.ttf'),
    );
    final brand = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Montserrat-Bold.ttf'),
    );
    final arabic = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
    );
    final logo = await rootBundle.loadString(AppImages.logoMarkRed);

    final document = pw.Document(
      title: 'Fee statement',
      author: 'Al Mahabbah Schools',
      theme: pw.ThemeData.withFont(base: regular, bold: brand),
    );
    final student = statement.student;
    final List<List<String>> rows;
    final double total;
    final double paid;
    final double remaining;
    if (installments == null) {
      rows = [
        for (final fee in statement.fees)
          [fee.name, _account(fee.bankAccount), _money(fee.amount)],
      ];
      total = statement.totalAmount;
      paid = statement.paidAmount;
      remaining = statement.remainingBalance;
    } else {
      rows = [
        for (final installment in installments)
          [
            installment.feeName,
            _account(installment.bankAccount),
            installment.label,
            _money(installment.amount),
          ],
      ];
      total = installments.fold(0, (sum, i) => sum + (i.amount ?? 0));
      paid = 0;
      remaining = total;
    }
    // Always on the installments being paid, like the school's; on the
    // whole statement only while some are being settled.
    final underSettlement =
        installments != null ||
        statement.installments.any(
          (installment) =>
              installment.status == InstallmentStatus.underSettlement,
        );

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(56, 48, 56, 48),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(36),
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _blush, width: 0.8),
                ),
              ),
            ),
          ),
        ),
        build: (context) => [
          _logo(logo, brand),
          pw.SizedBox(height: 14),
          _spaced('AL MAHABBAH SCHOOLS', brand, size: 10, spacing: 2.5),
          pw.SizedBox(height: 10),
          pw.Divider(color: _ink, thickness: 1.2, height: 1.2),
          pw.SizedBox(height: 16),
          _spaced('OFFICIAL FEE STATEMENT', brand, size: 13, spacing: 4),
          pw.SizedBox(height: 16),
          pw.Divider(color: _ink, thickness: 1.2, height: 1.2),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 9, color: _slate),
                children: [
                  const pw.TextSpan(text: 'Statement Date: '),
                  pw.TextSpan(
                    text: DateFormat('M/d/yyyy').format(date ?? DateTime.now()),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 18),
          _section('STUDENT INFORMATION', brand),
          _infoTable([
            (
              'Student Name',
              student.nameAr.isNotEmpty ? student.nameAr : student.name,
            ),
            ('National ID', student.nationalId),
            ('Grade', student.grade),
          ], arabic),
          pw.SizedBox(height: 18),
          _section(
            installments == null ? 'FEE STATEMENT' : 'INSTALLMENT SCHEDULE',
            brand,
          ),
          _feesTable(
            headers: [
              'Fee Type',
              'Bank Account No.',
              if (installments != null) 'Installment',
              'Amount (EGP)',
            ],
            rows: rows,
            boldNames: installments == null,
            arabic: arabic,
          ),
          _totalsTable([
            ('Total Amount', total),
            ('Paid Amount', paid),
            ('Remaining Balance', remaining),
          ]),
          if (underSettlement) ...[
            pw.SizedBox(height: 18),
            _section('SETTLEMENT NOTICE', brand),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _border, width: 0.7),
              ),
              child: pw.Text(
                'These fees are under settlement.',
                style: const pw.TextStyle(fontSize: 9.5, color: _slate),
              ),
            ),
          ],
          pw.SizedBox(height: 22),
          pw.Divider(color: _line, thickness: 0.7, height: 0.7),
          pw.SizedBox(height: 14),
          pw.Center(
            child: pw.Text(
              'Finance Department — Al Mahabbah Schools',
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                color: _ink,
              ),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text(
              'This is a system-generated statement.',
              style: const pw.TextStyle(fontSize: 8.5, color: _mist),
            ),
          ),
        ],
      ),
    );

    return FeeStatementPdfFile(
      name: 'fee-statement-${student.nationalId}.pdf',
      bytes: await document.save(),
    );
  }

  static const _ink = PdfColor.fromInt(0xFF252B42);
  static const _slate = PdfColor.fromInt(0xFF5C6070);
  static const _mist = PdfColor.fromInt(0xFFA3A7B4);
  static const _line = PdfColor.fromInt(0xFFE6E7EC);
  static const _border = PdfColor.fromInt(0xFFA9AEBF);
  static const _cellColor = PdfColor.fromInt(0xFFF8F9FB);
  static const _blush = PdfColor.fromInt(0xFFF8E3E6);

  static PdfColor _color(Color color) => PdfColor.fromInt(color.toARGB32());

  /// "18,000"; may have piasters ("1,500.5"). Not set yet: a dash.
  static String _money(double? amount) =>
      amount == null ? '—' : NumberFormat('#,##0.##', 'en').format(amount);

  /// "••••••••/446" in asterisks, which every font has.
  static String _account(String account) => account.replaceAll('•', '*');

  static pw.TextDirection _direction(String text) =>
      Bidi.detectRtlDirectionality(text)
      ? pw.TextDirection.rtl
      : pw.TextDirection.ltr;

  static pw.Widget _logo(String svg, pw.Font brand) => pw.Center(
    child: pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SvgImage(svg: svg, height: 40),
        pw.SizedBox(width: 8),
        pw.Text(
          'Al Mahabbah\nSchools',
          style: pw.TextStyle(
            font: brand,
            fontSize: 19,
            lineSpacing: -4,
            color: _color(AppColors.charcoal),
          ),
        ),
      ],
    ),
  );

  static pw.Widget _spaced(
    String text,
    pw.Font font, {
    required double size,
    required double spacing,
  }) => pw.Center(
    child: pw.Text(
      text,
      style: pw.TextStyle(
        font: font,
        fontSize: size,
        letterSpacing: spacing,
        color: _ink,
      ),
    ),
  );

  /// "STUDENT INFORMATION", underlined.
  static pw.Widget _section(String title, pw.Font brand) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: brand,
            fontSize: 8.5,
            letterSpacing: 2.5,
            color: _ink,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Divider(color: _ink, thickness: 1.2, height: 1.2),
      ],
    ),
  );

  /// Arabic (a name as the school wrote it) in [arabic], unbolded like the
  /// school's statement; Montserrat has no Arabic letters.
  static pw.Widget _cellText(
    String text, {
    bool bold = false,
    PdfColor color = _ink,
    double size = 10,
    pw.TextAlign align = pw.TextAlign.left,
    pw.Font? arabic,
  }) {
    final direction = _direction(text);
    final isArabic = arabic != null && direction == pw.TextDirection.rtl;
    return pw.Text(
      text,
      textDirection: direction,
      textAlign: align,
      style: pw.TextStyle(
        font: isArabic ? arabic : null,
        fontBold: isArabic ? arabic : null,
        fontSize: isArabic ? size - 0.5 : size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
      ),
    );
  }

  static const _padding = pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8);

  /// A cell's [child], centred down the row: an Arabic line is taller.
  static pw.Widget _cell(
    pw.Widget child, {
    PdfColor? color,
    bool end = false,
  }) => pw.Container(
    color: color,
    padding: _padding,
    alignment: end ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
    child: child,
  );

  static pw.Widget _infoTable(List<(String, String)> rows, pw.Font arabic) =>
      pw.Table(
        border: pw.TableBorder.all(color: _border, width: 0.7),
        columnWidths: const {
          0: pw.FlexColumnWidth(1),
          1: pw.FlexColumnWidth(2.1),
        },
        children: [
          for (final (label, value) in rows)
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.full,
              children: [
                _cell(
                  _cellText(label, bold: true, color: _slate, size: 9.5),
                  color: _cellColor,
                ),
                _cell(_cellText(value, bold: true, arabic: arabic)),
              ],
            ),
        ],
      );

  static pw.Widget _feesTable({
    required List<String> headers,
    required List<List<String>> rows,
    required bool boldNames,
    required pw.Font arabic,
  }) {
    final last = headers.length - 1;
    // As wide as the school's: the account widest, the installment
    // narrowest; with no installment column, the fee and the account share
    // its width.
    final widths = headers.length == 4
        ? const [1.62, 1.9, 1.33, 1.57]
        : const [2.28, 2.57, 1.57];
    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.7),
      columnWidths: {
        for (final (i, width) in widths.indexed) i: pw.FlexColumnWidth(width),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _cellColor),
          children: [
            for (final (i, header) in headers.indexed)
              _cell(
                _cellText(
                  header,
                  bold: true,
                  align: i == last ? pw.TextAlign.right : pw.TextAlign.left,
                ),
                end: i == last,
              ),
          ],
        ),
        for (final row in rows)
          pw.TableRow(
            verticalAlignment: pw.TableCellVerticalAlignment.full,
            children: [
              for (final (i, value) in row.indexed)
                i == last
                    ? _cell(
                        _cellText(value, bold: true, align: pw.TextAlign.right),
                        end: true,
                      )
                    : _cell(
                        _cellText(
                          value,
                          bold: i == 0 && boldNames,
                          color: i == 0 && boldNames ? _ink : _slate,
                          arabic: arabic,
                        ),
                      ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _totalsTable(List<(String, double)> rows) => pw.Table(
    border: const pw.TableBorder(
      left: pw.BorderSide(color: _border, width: 0.7),
      right: pw.BorderSide(color: _border, width: 0.7),
      bottom: pw.BorderSide(color: _border, width: 0.7),
      horizontalInside: pw.BorderSide(color: _border, width: 0.7),
      verticalInside: pw.BorderSide(color: _border, width: 0.7),
    ),
    columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2.1)},
    children: [
      for (final (label, amount) in rows)
        pw.TableRow(
          children: [
            pw.Padding(
              padding: _padding,
              child: _cellText(label, bold: true, size: 10.5),
            ),
            pw.Padding(
              padding: _padding,
              child: _cellText(
                _money(amount),
                bold: true,
                size: 11,
                align: pw.TextAlign.right,
              ),
            ),
          ],
        ),
    ],
  );
}
