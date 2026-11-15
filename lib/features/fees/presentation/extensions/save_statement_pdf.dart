import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pdf/fee_statement_pdf_file.dart';

extension SaveStatementPdf on BuildContext {
  /// Asks where to save [file] (Downloads by default) and says once it's
  /// there. Nothing happens if the parent closes the picker.
  Future<void> saveStatementPdf(FeeStatementPdfFile file) async {
    final l10n = this.l10n;
    try {
      final saved = await FilePicker.saveFile(
        dialogTitle: l10n.downloadPdf,
        fileName: file.name,
        bytes: file.bytes,
        mimeType: 'application/pdf',
      );
      if (saved != null && mounted) showSnackBar(l10n.feeStatementSaved);
    } on Exception {
      if (mounted) showSnackBar(l10n.feeStatementNotSaved, isError: true);
    }
  }
}
