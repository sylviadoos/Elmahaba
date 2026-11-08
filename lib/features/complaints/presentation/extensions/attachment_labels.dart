import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';

extension AttachmentTypes on BuildContext {
  /// "JPG, PNG, PDF, DOC, DOCX" ("jpeg" goes with "jpg"). On an Arabic page
  /// kept left to right as one piece, so its parts don't swap places when
  /// a line breaks.
  String get attachmentTypesLabel {
    final types = [
      for (final extension in ComplaintAttachmentRules.extensions)
        if (extension != 'jpeg') extension.toUpperCase(),
    ].join(', ');
    // Left-to-right isolate (U+2066) … pop directional isolate (U+2069).
    return isRtl
        ? '${String.fromCharCode(0x2066)}$types'
              '${String.fromCharCode(0x2069)}'
        : types;
  }
}

extension Megabytes on int {
  /// These bytes in MB, to one decimal place: "46.0".
  String get megabytesLabel => (this / (1024 * 1024)).toStringAsFixed(1);
}

extension PickedAttachmentLabel on PickedAttachment {
  /// Why it won't be sent; null when it will. [bytesLeft] of the total is
  /// still free.
  String? problemLabel(BuildContext context, {required int bytesLeft}) {
    final l10n = context.l10n;
    return switch (problem) {
      null => null,
      AttachmentProblem.typeNotAllowed => l10n.attachmentTypeNotAllowed(
        context.attachmentTypesLabel,
      ),
      AttachmentProblem.tooLarge => l10n.attachmentTooLarge(
        size.megabytesLabel,
        ComplaintAttachmentRules.maxMegabytes,
      ),
      AttachmentProblem.overTotal when bytesLeft == 0 =>
        l10n.attachmentOverTotalFull(
          ComplaintAttachmentRules.maxTotalMegabytes,
        ),
      AttachmentProblem.overTotal => l10n.attachmentOverTotal(
        ComplaintAttachmentRules.maxTotalMegabytes,
        bytesLeft.megabytesLabel,
      ),
      AttachmentProblem.rejected => l10n.attachmentRejected,
    };
  }
}

extension PickedAttachmentsLabels on List<PickedAttachment> {
  /// "1 / 5 files": the ones that will be sent.
  String countLabel(BuildContext context) => context.l10n.attachmentsCount(
    valid.length,
    ComplaintAttachmentRules.maxFiles,
  );

  /// "You can add 4 more · Max 10 MB each"; null once no more fit.
  String? roomLabel(BuildContext context) => canAddMore
      ? context.l10n.attachmentsRoomLeft(
          roomLeft,
          ComplaintAttachmentRules.maxMegabytes,
        )
      : null;

  /// "22.6 MB left of 25 MB"; null before any file is picked.
  String? spaceLeftLabel(BuildContext context) => valid.isEmpty
      ? null
      : context.l10n.attachmentsSpaceLeft(
          bytesLeft.megabytesLabel,
          ComplaintAttachmentRules.maxTotalMegabytes,
        );

  /// Why no more fit: as many files as allowed, or the whole total used;
  /// null while more fit.
  String? fullLabel(BuildContext context) {
    final l10n = context.l10n;
    if (roomLeft == 0) {
      return l10n.attachmentsMaxReached(ComplaintAttachmentRules.maxFiles);
    }
    if (bytesLeft == 0) {
      return l10n.attachmentsTotalFull(
        ComplaintAttachmentRules.maxTotalMegabytes,
      );
    }
    return null;
  }
}
