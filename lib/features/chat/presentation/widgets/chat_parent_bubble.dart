import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/linked_text.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_bloc_image_source.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_attachment_kind.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_labels.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_attachment_link.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_image_grid.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_reply_quote.dart';

/// The parent's message: a red bubble on the end side with what it
/// answers, its text and files, and "You · 10:15" ("You · Omar · 10:15"
/// with [showChildren]).
class ChatParentBubble extends StatelessWidget {
  const ChatParentBubble({
    super.key,
    required this.item,
    required this.answered,
    this.showChildren = false,
  });

  final ChatItemEntity item;

  /// What it answers, in a line; null when it answers nothing.
  final String? answered;

  /// Names the children it's about: the chat shows every child's.
  final bool showChildren;

  /// The bubble's widest, and its side padding (design px).
  static const double _maxWidth = 270;
  static const double _padding = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final answered = this.answered;
    // Photos fill the bubble; other files are links to open.
    final images = [
      for (final attachment in item.attachments)
        if (attachment.isImage) attachment,
    ];

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        constraints: BoxConstraints(maxWidth: _maxWidth.w),
        padding: EdgeInsets.symmetric(horizontal: _padding.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.actionRed,
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(16.r),
            topEnd: Radius.circular(4.r),
            bottomStart: Radius.circular(16.r),
            bottomEnd: Radius.circular(16.r),
          ),
        ),
        // As wide as its widest line, up to the bubble's limit.
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6.h,
            children: [
              if (answered != null)
                ChatReplyQuote(
                  label: l10n.inReplyTo,
                  text: answered,
                  onRed: true,
                ),
              if (item.isDeleted)
                Text(
                  l10n.deletedMessage,
                  style: textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                )
              else ...[
                if (item.text.isNotEmpty)
                  // Links in it open in the browser by a tap.
                  LinkedText(
                    item.text,
                    // In the language it was written in, on the page's side.
                    textDirection: item.textDirection,
                    textAlign: context.isRtl ? TextAlign.right : TextAlign.left,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                if (images.isNotEmpty)
                  ChatImageGrid(
                    source: const ChatBlocImageSource(),
                    images: images,
                    width: (_maxWidth - 2 * _padding).w,
                    onRed: true,
                  ),
                for (final attachment in item.attachments)
                  if (!attachment.isImage)
                    ChatAttachmentLink(attachment, onRed: true),
              ],
              Text(
                [
                  l10n.you,
                  if (showChildren)
                    // Sent about none of them: a general message.
                    item.children.isEmpty
                        ? l10n.chatGeneral
                        : item.childrenLabel(context),
                  item.timeLabel(context),
                  if (item.isEdited) l10n.edited,
                ].where((part) => part.isNotEmpty).join(' · '),
                textAlign: TextAlign.end,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
