import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_installment_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/save_statement_pdf.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pdf/fee_statement_pdf.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pdf/fee_statement_pdf_file.dart';

/// "Preview" and "Download PDF" of the official fee statement, side by
/// side, outlined in red: every fee, or the [installments] being paid
/// (none ticked: nothing to show, so they're off).
class StatementPdfButtons extends StatefulWidget {
  const StatementPdfButtons({
    super.key,
    required this.statement,
    this.installments,
    this.enabled = true,
  });

  final FeeStatementEntity statement;

  /// The installments being paid; null for every fee.
  final List<FeeInstallmentEntity>? installments;

  /// False keeps them off, e.g. installments ticked out of order.
  final bool enabled;

  @override
  State<StatementPdfButtons> createState() => _StatementPdfButtonsState();
}

class _StatementPdfButtonsState extends State<StatementPdfButtons> {
  /// Making the PDF for one of them, so neither starts another.
  bool _busy = false;

  Future<void> _withPdf(
    Future<void> Function(FeeStatementPdfFile file) use,
  ) async {
    setState(() => _busy = true);
    try {
      final file = await FeeStatementPdf.build(
        widget.statement,
        installments: widget.installments,
      );
      if (mounted) await use(file);
    } on Exception {
      if (mounted) {
        context.showSnackBar(context.l10n.feeStatementFailed, isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Opened, not waited on: the push's future ends only when the page is
  // popped, and never when something else takes it away (a notification
  // opened, Home) — the buttons would stay off until the app restarts.
  void _preview() => _withPdf((file) async {
    unawaited(context.push(AppRoutes.feeStatementPreview, extra: file));
  });

  void _download() => _withPdf(context.saveStatementPdf);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enabled =
        widget.enabled && !_busy && (widget.installments?.isNotEmpty ?? true);
    final style = OutlinedButton.styleFrom(
      foregroundColor: AppColors.actionRed,
      minimumSize: Size.fromHeight(50.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      side: BorderSide(
        color: enabled ? AppColors.actionRed : AppColors.rose,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      textStyle: context.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    return Row(
      spacing: 10.w,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled ? _preview : null,
            style: style,
            icon: AppSvgIcon(AppIcons.eye, size: 18.r),
            label: Text(l10n.preview),
          ),
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled ? _download : null,
            style: style,
            icon: AppSvgIcon(AppIcons.download, size: 18.r),
            label: Text(l10n.downloadPdf),
          ),
        ),
      ],
    );
  }
}
