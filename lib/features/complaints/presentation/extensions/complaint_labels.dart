import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_category_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_status.dart';

/// [arabic] in Arabic when the school wrote one, else [english].
String _inAppLanguage(BuildContext context, String english, String arabic) =>
    Localizations.localeOf(context).languageCode == AppConstants.arKey &&
        arabic.isNotEmpty
    ? arabic
    : english;

extension ComplaintCategoryLabel on ComplaintCategoryEntity {
  String name(BuildContext context) => _inAppLanguage(context, nameEn, nameAr);
}

extension ComplaintStatusLabel on ComplaintStatus {
  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      ComplaintStatus.submitted => l10n.statusSubmitted,
      ComplaintStatus.underReview => l10n.statusUnderReview,
      ComplaintStatus.awaitingParentResponse => l10n.statusAwaitingReply,
      ComplaintStatus.resolved => l10n.statusResolved,
      ComplaintStatus.rejected => l10n.statusRejected,
    };
  }

  /// The badge's (background, text) colors.
  (Color, Color) get colors => switch (this) {
    ComplaintStatus.submitted => (AppColors.blush, AppColors.mahabbahRed),
    ComplaintStatus.underReview => (AppColors.warningBg, AppColors.warning),
    ComplaintStatus.awaitingParentResponse => (
      AppColors.infoBg,
      AppColors.info,
    ),
    ComplaintStatus.resolved => (AppColors.successBg, AppColors.success),
    ComplaintStatus.rejected => (AppColors.hairline, AppColors.slate),
  };
}

extension ComplaintDisplay on ComplaintEntity {
  /// "CMP-2026-00012", kept left-to-right inside Arabic text.
  String get referenceLabel => reference.ltrIsolated;

  String categoryName(BuildContext context) =>
      _inAppLanguage(context, categoryEn, categoryAr);

  /// The child's name, or "General".
  String aboutLabel(BuildContext context) {
    final name = _inAppLanguage(context, childName, childNameAr);
    return name.isEmpty ? context.l10n.complaintGeneral : name;
  }

  /// "Submitted 3 Nov · Last update 5 Nov"; what's known of it.
  String datesLabel(BuildContext context) {
    final l10n = context.l10n;
    return [
      if (submittedAt case final submitted?)
        l10n.submittedOn(submitted.dayLabel(context)),
      if (lastUpdate case final updated?)
        l10n.lastUpdateOn(updated.dayLabel(context)),
    ].join(' · ');
  }
}

extension ComplaintDates on DateTime {
  /// e.g. "3 Nov".
  String dayLabel(BuildContext context) => DateFormat(
    'd MMM',
    Localizations.localeOf(context).toString(),
  ).format(this);

  /// e.g. "3 Nov 2026, 09:15".
  String dateTimeLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final comma = locale.startsWith(AppConstants.arKey) ? '،' : ',';
    return '${DateFormat('d MMM y', locale).format(this)}$comma '
        '${DateFormat.Hm(locale).format(this)}';
  }
}

extension ComplaintFileSize on int {
  /// Bytes as "240 KB" or "1.2 MB".
  String fileSizeLabel(BuildContext context) {
    const kilobyte = 1024;
    const megabyte = kilobyte * kilobyte;
    final l10n = context.l10n;
    return this >= megabyte
        ? l10n.fileSizeMb((this / megabyte).toStringAsFixed(1))
        : l10n.fileSizeKb((this / kilobyte).round().toString());
  }
}

extension ComplaintAttachmentLabel on ComplaintAttachmentEntity {
  /// "240 KB · Tap to open", or "Checking file…" while it can't be opened.
  String metaLabel(BuildContext context) => isAvailable
      ? '${size.fileSizeLabel(context)} · ${context.l10n.tapToOpen}'
      : context.l10n.checkingFile;
}
