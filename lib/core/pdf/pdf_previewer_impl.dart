import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:printing/printing.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/pdf/pdf_previewer.dart';

@LazySingleton(as: PdfPreviewer)
class PdfPreviewerImpl implements PdfPreviewer {
  /// Sharp on a phone at the size a chat shows it, light to save.
  static const double _dpi = 110;

  @override
  Future<String> firstPage(String pdfPath) async {
    final preview = File('$pdfPath.preview.png');
    if (await preview.exists()) return preview.path;
    final document = await File(pdfPath).readAsBytes();
    await for (final page in Printing.raster(
      document,
      pages: const [0],
      dpi: _dpi,
    )) {
      // Written apart, then named: only a whole picture is ever taken as
      // done, even if the app closes while it's written (the half is
      // cleared with the temporary files).
      final part = File(
        '${preview.path}.${DateTime.now().microsecondsSinceEpoch}.part',
      );
      await part.writeAsBytes(await page.toPng(), flush: true);
      await part.rename(preview.path);
      return preview.path;
    }
    // A PDF without pages.
    throw const UnknownException();
  }
}
