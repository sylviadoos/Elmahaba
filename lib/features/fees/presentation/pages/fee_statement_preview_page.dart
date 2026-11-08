import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_loading.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/save_statement_pdf.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pdf/fee_statement_pdf_file.dart';

/// The fee statement PDF as it will be saved, to check it first; "Download
/// PDF" under it.
class FeeStatementPreviewPage extends StatelessWidget {
  const FeeStatementPreviewPage({super.key, required this.file});

  final FeeStatementPdfFile file;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RedHeader(
              horizontalPadding: 16,
              bottomPadding: 36,
              watermarkTop: 20,
              watermarkSize: const Size(200, 143),
              waveColor: AppColors.surface,
              child: Row(
                spacing: 10.w,
                children: [
                  const AppBackButton(fallbackRoute: AppRoutes.fees),
                  Expanded(
                    child: Text(
                      l10n.feeStatement,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: 20.sp,
                        height: 24 / 20,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PdfPreview(
                build: (_) async => file.bytes,
                pdfFileName: file.name,
                useActions: false,
                allowPrinting: false,
                allowSharing: false,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                loadingWidget: const AppLoading(),
                scrollViewDecoration: const BoxDecoration(
                  color: AppColors.surface,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                20.w,
                12.h,
                20.w,
                math.max(16.h, MediaQuery.paddingOf(context).bottom + 8),
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: AppButton(
                label: l10n.downloadPdf,
                icon: AppSvgIcon(AppIcons.download, size: 20.r),
                onPressed: () => context.saveStatementPdf(file),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
