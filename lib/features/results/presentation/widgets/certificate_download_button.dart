import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/pdf/certificate_pdf_file.dart';
import 'package:al_mahhaba_school/features/results/presentation/pdf/monthly_certificate_pdf.dart';

/// "Download certificate (PDF)", outlined in red: the school's monthly
/// certificate with the marks written on it, saved where the parent picks
/// (Downloads by default).
class CertificateDownloadButton extends StatefulWidget {
  const CertificateDownloadButton({super.key, required this.certificate});

  final MonthlyCertificateEntity certificate;

  @override
  State<CertificateDownloadButton> createState() =>
      _CertificateDownloadButtonState();
}

class _CertificateDownloadButtonState extends State<CertificateDownloadButton> {
  /// Making or saving it, so a second tap doesn't start another.
  bool _busy = false;

  Future<void> _download() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final CertificatePdfFile file;
      try {
        file = await MonthlyCertificatePdf.build(widget.certificate);
      } catch (error) {
        // Whatever stopped it, say so, rather than nothing happening. A bug
        // still goes on to the crash reports.
        if (mounted) {
          context.showSnackBar(l10n.certificateFailed, isError: true);
        }
        if (error is Error) rethrow;
        return;
      }
      if (!mounted) return;
      try {
        final saved = await FilePicker.saveFile(
          dialogTitle: l10n.downloadCertificate,
          fileName: file.name,
          bytes: file.bytes,
          mimeType: 'application/pdf',
        );
        // Nothing to say if the parent closed the picker.
        if (saved != null && mounted) {
          context.showSnackBar(l10n.certificateSaved);
        }
      } on Exception {
        if (mounted) {
          context.showSnackBar(l10n.certificateNotSaved, isError: true);
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _busy ? null : _download,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.actionRed,
        minimumSize: Size.fromHeight(50.h),
        side: BorderSide(
          color: _busy ? AppColors.rose : AppColors.actionRed,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        textStyle: context.textTheme.labelLarge?.copyWith(fontSize: 15.sp),
      ),
      icon: _busy
          ? SizedBox.square(
              dimension: 18.r,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.actionRed,
              ),
            )
          : AppSvgIcon(AppIcons.download, size: 18.r),
      label: Text(context.l10n.downloadCertificate),
    );
  }
}
