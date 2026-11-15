import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/results/presentation/pdf/certificate_pdf_file.dart';

extension SaveCertificatePdf on BuildContext {
  /// Asks where to save [file] (Downloads by default) and says once it's
  /// there. Nothing happens if the parent closes the picker.
  Future<void> saveCertificatePdf(CertificatePdfFile file) async {
    final l10n = this.l10n;
    try {
      final saved = await FilePicker.saveFile(
        dialogTitle: l10n.downloadCertificate,
        fileName: file.name,
        bytes: file.bytes,
        mimeType: 'application/pdf',
      );
      if (saved != null && mounted) showSnackBar(l10n.certificateSaved);
    } on Exception {
      if (mounted) showSnackBar(l10n.certificateNotSaved, isError: true);
    }
  }
}
