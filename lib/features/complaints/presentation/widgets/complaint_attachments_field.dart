import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_labels.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/add_attachment_button.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_list.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_notes.dart';

/// "Attachments (optional)": how many of the most allowed are picked, what
/// the school takes, the [files] (each with its kind and size, how far it
/// got while they're sent, or why it won't be sent), then "Add file" with
/// what still fits, or why nothing more does.
class ComplaintAttachmentsField extends StatelessWidget {
  const ComplaintAttachmentsField({
    super.key,
    required this.files,
    this.upload,
    required this.onAdd,
    required this.onRemove,
  });

  final List<PickedAttachment> files;

  /// While the complaint is being sent.
  final UploadProgress? upload;

  /// Null while the files can't change (the complaint is being sent).
  final VoidCallback? onAdd;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final spaceLeft = files.spaceLeftLabel(context);
    final full = files.fullLabel(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8.h,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4.h,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '${l10n.complaintAttachments} ',
                      children: [
                        TextSpan(
                          text: l10n.optionalNote,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  files.countLabel(context),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
            const AttachmentLimitsNote(),
          ],
        ),
        if (files.isNotEmpty)
          AttachmentList(files: files, upload: upload, onRemove: onRemove),
        if (full != null)
          AttachmentsFullNote(full)
        else ...[
          AddAttachmentButton(
            onPressed: onAdd,
            subtitle: files.roomLabel(context),
          ),
          if (spaceLeft != null)
            Text(
              spaceLeft,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                color: AppColors.slate,
              ),
            ),
        ],
      ],
    );
  }
}
