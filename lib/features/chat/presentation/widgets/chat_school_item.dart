import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_link_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_labels.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_accent_card.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_attachment_link.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_outline_action.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_read_mark.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/message_kind_chip.dart';

/// Something from the school: who it's for and when, "New" or "Read", then
/// a card with its title, text and files, a button to the screen it's
/// about, and "Reply" when the school takes an answer.
class ChatSchoolItem extends StatelessWidget {
  const ChatSchoolItem({
    super.key,
    required this.item,
    required this.onOpenLink,
    this.onReply,
  });

  final ChatItemEntity item;
  final ValueChanged<ChatLinkEntity> onOpenLink;

  /// Null when it can't be answered.
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final link = item.link;
    final onReply = this.onReply;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8.h,
      children: [
        Row(
          spacing: 8.w,
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: MessageKindChip(
                  isGeneral: item.isGeneral,
                  label: [
                    item.isGeneral ? l10n.chatGeneral : l10n.chatPrivate,
                    item.aboutLabel(context),
                    item.timeLabel(context),
                    if (item.isEdited) l10n.edited,
                  ].where((part) => part.isNotEmpty).join(' · '),
                  bold: true,
                ),
              ),
            ),
            ChatReadMark(isRead: item.isRead),
          ],
        ),
        ChatAccentCard(
          isGeneral: item.isGeneral,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10.h,
            children: [
              Row(
                spacing: 10.w,
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.blush,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: SvgPicture.asset(
                      AppImages.logoMarkRed,
                      width: 24.r,
                      height: 17.r,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      // Messages have no title: who sent it, then.
                      item.title ?? l10n.schoolName,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 15.sp,
                        height: 20 / 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.isDeleted)
                Text(
                  l10n.deletedMessage,
                  style: textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.mist,
                  ),
                )
              else ...[
                if (item.text.isNotEmpty)
                  Text(
                    item.text,
                    // In the language it was written in, on the page's side.
                    textDirection: item.textDirection,
                    textAlign: context.isRtl ? TextAlign.right : TextAlign.left,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate,
                    ),
                  ),
                for (final attachment in item.attachments)
                  ChatAttachmentLink(attachment),
                if (link != null)
                  ChatOutlineAction(
                    label: link.screen.label(context),
                    onTap: () => onOpenLink(link),
                  ),
              ],
              if (onReply != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: onReply,
                    icon: AppSvgIcon(AppIcons.reply, size: 16.r),
                    label: Text(l10n.reply),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.actionRed,
                      iconColor: AppColors.actionRed,
                      minimumSize: Size(0, 36.h),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: textTheme.labelLarge?.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
