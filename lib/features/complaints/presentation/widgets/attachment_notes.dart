import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_labels.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';

TextStyle? _noteStyle(BuildContext context) => context.textTheme.bodySmall
    ?.copyWith(fontSize: 12.sp, height: 16 / 12, color: AppColors.slate);

/// What the school takes: the kinds of file, how big each and all of them
/// together. [compact]: in one line.
class AttachmentLimitsNote extends StatelessWidget {
  const AttachmentLimitsNote({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = _noteStyle(context);
    final types = context.attachmentTypesLabel;
    if (compact) {
      return Text(
        l10n.attachmentLimitsShort(
          types,
          ComplaintAttachmentRules.maxMegabytes,
          ComplaintAttachmentRules.maxTotalMegabytes,
        ),
        style: style,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.attachmentFormats(types), style: style),
        Text(
          l10n.attachmentMaxFileSize(ComplaintAttachmentRules.maxMegabytes),
          style: style,
        ),
        Text(
          l10n.attachmentMaxTotalSize(
            ComplaintAttachmentRules.maxTotalMegabytes,
          ),
          style: style,
        ),
      ],
    );
  }
}

/// What else fits: "1 / 5 files · You can add 4 more · Max 10 MB each"
/// ([withCount]) and "22.6 MB left of 25 MB"; once no more fit, why.
class AttachmentsCapacity extends StatelessWidget {
  const AttachmentsCapacity({
    super.key,
    required this.files,
    this.withCount = true,
  });

  final List<PickedAttachment> files;
  final bool withCount;

  @override
  Widget build(BuildContext context) {
    final full = files.fullLabel(context);
    if (full != null) return AttachmentsFullNote(full);
    final style = _noteStyle(context);
    final spaceLeft = files.spaceLeftLabel(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          [
            if (withCount) files.countLabel(context),
            ?files.roomLabel(context),
          ].join(' · '),
          style: style,
        ),
        if (spaceLeft != null) Text(spaceLeft, style: style),
      ],
    );
  }
}

/// Why no more files fit ([text]), in place of adding one.
class AttachmentsFullNote extends StatelessWidget {
  const AttachmentsFullNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.w,
        children: [
          AppSvgIcon(AppIcons.info, size: 16.r, color: AppColors.warning),
          Expanded(
            child: Text(
              text,
              style: _noteStyle(context)?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
