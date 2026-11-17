import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/save_certificate_pdf.dart';
import 'package:al_mahhaba_school/features/results/presentation/pdf/certificate_pdf_file.dart';
import 'package:al_mahhaba_school/features/results/presentation/pdf/monthly_certificate_pdf.dart';

/// What the parent is waiting for; null while nothing is being made.
enum _Making { preview, download }

/// "Preview" over "Download certificate (PDF)", outlined in red: the
/// school's monthly certificate with the marks written on it, looked over
/// first or saved straight away (Downloads by default).
class CertificateDownloadButton extends StatefulWidget {
  const CertificateDownloadButton({super.key, required this.certificate});

  final MonthlyCertificateEntity certificate;

  @override
  State<CertificateDownloadButton> createState() =>
      _CertificateDownloadButtonState();
}

class _CertificateDownloadButtonState extends State<CertificateDownloadButton> {
  /// Which one the parent tapped; null while neither is working. Only it
  /// turns, and neither takes another tap meanwhile.
  _Making? _making;

  /// Makes the certificate, then [use]s it. Whatever stopped it, say so
  /// rather than nothing happening; a bug still goes on to the crash
  /// reports.
  Future<void> _withPdf(
    _Making making,
    Future<void> Function(CertificatePdfFile file) use,
  ) async {
    final l10n = context.l10n;
    setState(() => _making = making);
    try {
      final CertificatePdfFile file;
      try {
        file = await MonthlyCertificatePdf.build(widget.certificate);
      } catch (error) {
        if (mounted) {
          context.showSnackBar(l10n.certificateFailed, isError: true);
        }
        if (error is Error) rethrow;
        return;
      }
      if (mounted) await use(file);
    } finally {
      if (mounted) setState(() => _making = null);
    }
  }

  // Opened, not waited on: the push's future ends only when the page is
  // popped, and never when something else takes it away (a notification
  // opened, Home) — the button would turn until the app restarts.
  void _preview() => unawaited(
    _withPdf(_Making.preview, (file) async {
      unawaited(context.push(AppRoutes.certificatePreview, extra: file));
    }),
  );

  void _download() =>
      unawaited(_withPdf(_Making.download, context.saveCertificatePdf));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final making = _making;
    final style = OutlinedButton.styleFrom(
      foregroundColor: AppColors.actionRed,
      minimumSize: Size.fromHeight(50.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      side: BorderSide(
        color: making == null ? AppColors.actionRed : AppColors.rose,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      textStyle: context.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    /// One of them: turning while it's the one being waited for.
    Widget button(_Making which, String icon, String label, VoidCallback tap) =>
        OutlinedButton.icon(
          onPressed: making == null ? tap : null,
          style: style,
          icon: making == which
              ? SizedBox.square(
                  dimension: 18.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.actionRed,
                  ),
                )
              : AppSvgIcon(icon, size: 18.r),
          label: Text(label),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10.h,
      children: [
        button(_Making.preview, AppIcons.eye, l10n.preview, _preview),
        button(
          _Making.download,
          AppIcons.download,
          l10n.downloadCertificate,
          _download,
        ),
      ],
    );
  }
}
