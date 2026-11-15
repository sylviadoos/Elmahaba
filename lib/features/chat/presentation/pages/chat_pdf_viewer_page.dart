import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_pdf_args.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_file_opener.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_viewer_bar.dart';

/// A PDF from the chat or Homework full screen, on dark like a photo: its
/// pages one under another, a page double-tapped to zoom in (then
/// pinched). The bar closes it or opens it in another app (to save or
/// share it).
class ChatPdfViewerPage extends StatelessWidget {
  const ChatPdfViewerPage({super.key, required this.args});

  final ChatPdfArgs args;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChatViewerBar(
              title: args.fileName,
              onClose: context.pop,
              onOpenElsewhere: () => context.openOutside(args.path),
            ),
            Expanded(
              child: PdfPreview(
                build: (_) => File(args.path).readAsBytes(),
                pdfFileName: args.fileName,
                useActions: false,
                allowPrinting: false,
                allowSharing: false,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                maxPageWidth: 700,
                loadingWidget: const CircularProgressIndicator(
                  color: AppColors.white,
                ),
                onError: (context, _) => _CantShow(path: args.path),
                scrollViewDecoration: const BoxDecoration(
                  color: AppColors.darkBackground,
                ),
                // No shadow under the pages: the dark sets them apart.
                pdfPreviewPageDecoration: const BoxDecoration(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The PDF can't be drawn here: why, and "Open in another app".
class _CantShow extends StatelessWidget {
  const _CantShow({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12.h,
          children: [
            AppSvgIcon(
              AppIcons.alertCircle,
              size: 40.r,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
            Text(
              l10n.cantShowFile,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
              ),
            ),
            TextButton(
              onPressed: () => context.openOutside(path),
              style: TextButton.styleFrom(foregroundColor: AppColors.white),
              child: Text(l10n.openInAnotherApp),
            ),
          ],
        ),
      ),
    );
  }
}
