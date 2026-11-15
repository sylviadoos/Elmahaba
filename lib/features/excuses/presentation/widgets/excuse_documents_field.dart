import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_picker.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/add_attachment_button.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_tile.dart';

/// "Medical documents": the [files] picked so far out of the most [limits]
/// allow, "Add file" while there's room, which files are taken, and
/// [errorText] (none attached yet).
class ExcuseDocumentsField extends StatelessWidget {
  const ExcuseDocumentsField({
    super.key,
    required this.files,
    required this.limits,
    required this.onAdd,
    required this.onRemove,
    this.onPreview,
    this.label,
    this.errorText,
  });

  final List<PickedAttachment> files;
  final AttachmentLimits limits;

  /// Null while the files can't change (they're being sent).
  final VoidCallback? onAdd;
  final ValueChanged<int>? onRemove;

  /// Gets the index of a photo tapped, to show it bigger.
  final ValueChanged<int>? onPreview;

  /// "Medical documents" by default.
  final String? label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final note = textTheme.bodySmall?.copyWith(
      fontSize: 12.sp,
      height: 16 / 12,
      color: AppColors.slate,
    );
    final onRemove = this.onRemove;
    final onPreview = this.onPreview;
    final errorText = this.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8.h,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label ?? l10n.excuseDocuments,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${files.length} / ${limits.maxFiles}',
              textDirection: TextDirection.ltr,
              style: note,
            ),
          ],
        ),
        for (final (index, file) in files.indexed)
          AttachmentTile(
            file: file,
            onRemove: onRemove == null ? null : () => onRemove(index),
            onPreview: onPreview == null ? null : () => onPreview(index),
          ),
        if (files.length < limits.maxFiles)
          AddAttachmentButton(onPressed: onAdd),
        if (errorText != null)
          Text(
            errorText,
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        Text(
          l10n.excuseDocumentsRules(
            limits.typesLabel(context),
            limits.maxMegabytes,
            limits.maxFiles,
          ),
          style: note,
        ),
      ],
    );
  }
}
