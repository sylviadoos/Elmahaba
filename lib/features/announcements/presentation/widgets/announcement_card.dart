import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/announcement_image_source.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/extensions/announcement_labels.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/widgets/announcement_file_link.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_attachment_kind.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_labels.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_image_grid.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/homework/presentation/extensions/homework_labels.dart';

/// One announcement: who it's for ("New" while unread, "Ended" once it
/// expired), its title and text, when it was published (and until when it
/// stands), its photos (opened full screen) and its files.
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard(this.announcement, {super.key});

  final AnnouncementEntity announcement;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final direction = announcement.textDirection;
    final align = context.isRtl ? TextAlign.right : TextAlign.left;
    final audience = announcement.audience?.label(context) ?? '';
    final published = announcement.publishedAt?.toLocal().homeworkDayLabel(
      context,
    );
    final expiresAt = announcement.expiresAt;
    final until = expiresAt == null || announcement.isExpired
        ? null
        : expiresAt.toLocal().homeworkDayLabel(context);
    // Photos show in the card; other files are links to open.
    final images = [
      for (final attachment in announcement.attachments)
        if (attachment.isImage) attachment,
    ];

    // Flat: the border sets it apart, no shadow to paint as it scrolls.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.h,
          children: [
            Row(
              spacing: 8.w,
              children: [
                // Who it's for at the start; "New" or "Ended" at the end.
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _AudienceChip(
                      audience.isEmpty ? l10n.announcements : audience,
                    ),
                  ),
                ),
                if (announcement.isExpired)
                  _Chip(
                    l10n.announcementEnded,
                    color: AppColors.surface,
                    textColor: AppColors.slate,
                  )
                else if (!announcement.isRead)
                  _Chip(
                    l10n.homeworkNew,
                    color: AppColors.gold,
                    textColor: AppColors.goldText,
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4.h,
              children: [
                Text(
                  announcement.title,
                  textDirection: direction,
                  textAlign: align,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 16.sp,
                    height: 22 / 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (announcement.body.isNotEmpty)
                  Text(
                    announcement.body,
                    textDirection: direction,
                    textAlign: align,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate,
                    ),
                  ),
              ],
            ),
            if (published != null || until != null)
              Text(
                [
                  ?published,
                  if (announcement.isEdited) l10n.edited,
                  if (until != null) l10n.announcementUntil(until),
                ].join(' · '),
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  height: 16 / 12,
                  color: AppColors.slate,
                ),
              ),
            if (images.isNotEmpty)
              LayoutBuilder(
                builder: (_, constraints) => ChatImageGrid(
                  source: const AnnouncementImageSource(),
                  images: images,
                  width: constraints.maxWidth,
                ),
              ),
            for (final attachment in announcement.attachments)
              if (!attachment.isImage) AnnouncementFileLink(attachment),
          ],
        ),
      ),
    );
  }
}

/// Who it went to (e.g. "All parents"), with a megaphone, in the brand's
/// soft red.
class _AudienceChip extends StatelessWidget {
  const _AudienceChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: const ShapeDecoration(
        color: AppColors.blush,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6.w,
        children: [
          AppSvgIcon(
            AppIcons.megaphoneGeneral,
            size: 14.r,
            color: AppColors.mahabbahRed,
          ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                height: 16 / 12,
                fontWeight: FontWeight.w700,
                color: AppColors.mahabbahRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A short word at the card's top end: "New" or "Ended".
class _Chip extends StatelessWidget {
  const _Chip(this.label, {required this.color, required this.textColor});

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: ShapeDecoration(color: color, shape: const StadiumBorder()),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          fontSize: 11.sp,
          height: 15 / 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
