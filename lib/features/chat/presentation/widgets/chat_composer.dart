import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_reply_quote.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_list.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_notes.dart';

/// The message box at the bottom of the chat: whom it's about
/// ([recipients]), what it answers ([replyingTo], once "Reply" was tapped
/// on an item), the files picked (with what else fits and what the school
/// takes), why it wasn't sent ([errorText]), then "Attach", the text and
/// "Send".
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    this.recipients,
    this.replyingTo,
    required this.onCancelReply,
    required this.controller,
    required this.focusNode,
    required this.attachments,
    this.upload,
    required this.isSending,
    required this.onAttach,
    required this.onRemoveAttachment,
    required this.onSend,
    this.onChanged,
    this.errorText,
  });

  /// The children to pick from, when the chat shows every child's.
  final Widget? recipients;

  /// What the message answers, in a line; null when it answers nothing.
  final String? replyingTo;
  final VoidCallback onCancelReply;

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<PickedAttachment> attachments;

  /// While the message is being sent.
  final UploadProgress? upload;
  final bool isSending;

  /// Null once there's no room for more files.
  final VoidCallback? onAttach;
  final ValueChanged<int> onRemoveAttachment;

  /// Null while it can't be sent.
  final VoidCallback? onSend;

  /// The text was typed in.
  final ValueChanged<String>? onChanged;
  final String? errorText;

  /// Keeps the text as it is.
  static final _frozen = TextInputFormatter.withFunction(
    (oldValue, newValue) => oldValue,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final replyingTo = this.replyingTo;
    final errorText = this.errorText;
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(22.r),
      borderSide: BorderSide.none,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        12.w,
        10.h,
        12.w,
        math.max(12.h, MediaQuery.paddingOf(context).bottom + 8),
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8.h,
        children: [
          ?recipients,
          if (replyingTo != null)
            Row(
              spacing: 4.w,
              children: [
                Expanded(
                  child: ChatReplyQuote(
                    label: l10n.replyingTo,
                    text: replyingTo,
                  ),
                ),
                IconButton(
                  onPressed: isSending ? null : onCancelReply,
                  tooltip: l10n.cancelReply,
                  icon: AppSvgIcon(
                    AppIcons.close,
                    size: 18.r,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          if (attachments.isNotEmpty) ...[
            AttachmentList(
              files: attachments,
              upload: upload,
              onRemove: isSending ? null : onRemoveAttachment,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 2.h,
              children: [
                AttachmentsCapacity(files: attachments),
                const AttachmentLimitsNote(compact: true),
              ],
            ),
          ],
          if (errorText != null)
            Text(
              errorText,
              style: textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 6.w,
            children: [
              IconButton(
                onPressed: isSending ? null : onAttach,
                tooltip: l10n.attach,
                style: IconButton.styleFrom(
                  fixedSize: Size.square(44.r),
                  foregroundColor: AppColors.actionRed,
                  disabledForegroundColor: AppColors.mist,
                ),
                icon: AppSvgIcon(AppIcons.paperclip, size: 22.r),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  // Not readOnly while sending: that drops the keyboard. It
                  // stays up for the next one; what's typed meanwhile is
                  // ignored.
                  inputFormatters: isSending ? [_frozen] : null,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: l10n.messageHint,
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: AppColors.placeholder,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    border: fieldBorder,
                    enabledBorder: fieldBorder,
                    disabledBorder: fieldBorder,
                    focusedBorder: fieldBorder.copyWith(
                      borderSide: const BorderSide(color: AppColors.actionRed),
                    ),
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: isSending ? null : onSend,
                tooltip: l10n.send,
                style: IconButton.styleFrom(
                  fixedSize: Size.square(44.r),
                  backgroundColor: AppColors.actionRed,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.rose,
                ),
                icon: isSending
                    ? SizedBox.square(
                        dimension: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : AppSvgIcon(
                        AppIcons.send,
                        size: 20.r,
                        color: AppColors.white,
                        matchTextDirection: true,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
