import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_list.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_notes.dart';

/// "Add a reply" while the complaint is open: the text, the files picked
/// for it (with what else fits and what the school takes), "Attach" and
/// "Send reply"; why it wasn't sent ([errorText]), or that it was
/// ([sent]). Files alone make a reply.
class ComplaintReplyBox extends StatelessWidget {
  const ComplaintReplyBox({
    super.key,
    required this.controller,
    required this.attachments,
    this.upload,
    required this.isSending,
    required this.sent,
    required this.onAttach,
    required this.onRemoveAttachment,
    required this.onSend,
    this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final List<PickedAttachment> attachments;

  /// While the reply is being sent.
  final UploadProgress? upload;
  final bool isSending;
  final bool sent;

  /// Null once there's no room for more files.
  final VoidCallback? onAttach;
  final ValueChanged<int> onRemoveAttachment;

  /// Null while there's nothing to send: no text and no file that can go.
  final VoidCallback? onSend;

  /// The text was typed in.
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    );

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10.h,
        children: [
          AppTextField(
            label: l10n.addAReply,
            labelWeight: FontWeight.w600,
            labelGap: 10,
            hint: l10n.replyHint,
            controller: controller,
            minLines: 3,
            fillColor: AppColors.white,
            errorText: errorText,
            onChanged: onChanged,
          ),
          if (sent)
            Text(
              l10n.replySent,
              style: textTheme.bodySmall?.copyWith(color: AppColors.success),
            ),
          if (attachments.isNotEmpty)
            AttachmentList(
              files: attachments,
              upload: upload,
              onRemove: isSending ? null : onRemoveAttachment,
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4.h,
            children: [
              AttachmentsCapacity(files: attachments),
              const AttachmentLimitsNote(compact: true),
            ],
          ),
          Row(
            spacing: 10.w,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSending ? null : onAttach,
                  icon: AppSvgIcon(AppIcons.paperclip, size: 18.r),
                  label: Text(l10n.attach, overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(48.h),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    shape: buttonShape,
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.actionRed,
                    iconColor: AppColors.actionRed,
                    side: const BorderSide(
                      color: AppColors.actionRed,
                      width: 1.5,
                    ),
                    textStyle: textTheme.labelLarge?.copyWith(fontSize: 14.sp),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isSending ? null : onSend,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(48.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    shape: buttonShape,
                    textStyle: textTheme.labelLarge?.copyWith(fontSize: 15.sp),
                  ),
                  child: isSending
                      ? SizedBox.square(
                          dimension: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(l10n.sendReply, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
