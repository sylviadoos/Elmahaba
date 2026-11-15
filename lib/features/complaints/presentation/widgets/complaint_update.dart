import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_message_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_file_link.dart';

/// One message after the complaint: who wrote it (the school, red, or
/// "You") and when, what it says and its files. A line over it unless
/// it's the [first].
class ComplaintUpdate extends StatelessWidget {
  const ComplaintUpdate({
    super.key,
    required this.message,
    required this.first,
    required this.downloadingId,
    required this.onOpenAttachment,
  });

  final ComplaintMessageEntity message;
  final bool first;

  /// The attachment downloading now, if any.
  final int? downloadingId;
  final ValueChanged<ComplaintAttachmentEntity> onOpenAttachment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final fromParent = message.fromParent;
    final text = message.text;
    final sentAt = message.sentAt;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: first
            ? null
            : const Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8.h,
        children: [
          Row(
            spacing: 10.w,
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fromParent ? AppColors.blush : AppColors.mahabbahRed,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  fromParent ? l10n.you : l10n.schoolInitials,
                  maxLines: 1,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: fromParent ? AppColors.mahabbahRed : AppColors.white,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fromParent
                          ? l10n.you
                          : message.senderName.isEmpty
                          ? l10n.schoolAdministration
                          : message.senderName,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (sentAt != null)
                      Text(
                        sentAt.dateTimeLabel(context),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          height: 16 / 12,
                          color: AppColors.slate,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (text.isNotEmpty)
            Text(
              text,
              // In the language it was written in, on the page's side.
              textDirection: text.textDirection,
              textAlign: Directionality.of(context) == TextDirection.rtl
                  ? TextAlign.right
                  : TextAlign.left,
              style: textTheme.bodyMedium?.copyWith(height: 21 / 14),
            ),
          for (final attachment in message.attachments)
            ComplaintFileLink(
              attachment: attachment,
              isDownloading: attachment.id == downloadingId,
              onOpen: downloadingId == null
                  ? () => onOpenAttachment(attachment)
                  : null,
            ),
        ],
      ),
    );
  }
}
