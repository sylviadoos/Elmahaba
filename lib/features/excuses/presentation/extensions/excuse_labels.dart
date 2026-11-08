import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_picker.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_history_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_rules_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_status.dart';

extension ExcuseDay on DateTime {
  /// e.g. "Wednesday 4 November".
  String excuseDayLabel(BuildContext context) => DateFormat(
    'EEEE d MMMM',
    Localizations.localeOf(context).toString(),
  ).format(this);
}

extension ExcuseStatusLabel on ExcuseStatus {
  /// e.g. "Under review".
  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      ExcuseStatus.submitted || ExcuseStatus.unknown => l10n.excuseUnderReview,
      ExcuseStatus.infoRequired => l10n.excuseInfoRequired,
      ExcuseStatus.accepted => l10n.excuseAccepted,
      ExcuseStatus.rejected => l10n.excuseRejected,
    };
  }

  /// Its badge's text and background.
  (Color, Color) get colors => switch (this) {
    ExcuseStatus.submitted ||
    ExcuseStatus.unknown => (AppColors.info, AppColors.infoBg),
    ExcuseStatus.infoRequired => (AppColors.warning, AppColors.warningBg),
    ExcuseStatus.accepted => (AppColors.success, AppColors.successBg),
    ExcuseStatus.rejected => (AppColors.error, AppColors.errorBg),
  };
}

extension ExcuseRulesLimits on ExcuseRulesEntity {
  static const List<String> _photoTypes = ['jpg', 'jpeg', 'png'];

  /// What the file picker takes: the school's types ("jpeg" with "jpg",
  /// the same file), as many and as big as it says.
  AttachmentLimits get limits {
    final photos = [
      for (final type in allowedTypes)
        if (_photoTypes.contains(type)) type,
      if (allowedTypes.contains('jpg') && !allowedTypes.contains('jpeg'))
        'jpeg',
    ];
    return (
      photoExtensions: photos,
      documentExtensions: [
        for (final type in allowedTypes)
          if (!_photoTypes.contains(type)) type,
      ],
      maxFiles: maxDocuments,
      maxMegabytes: maxFileMegabytes,
    );
  }
}

extension ExcuseHistoryLabel on ExcuseHistoryEntity {
  /// e.g. "Excuse sent"; the API's word for a step the app doesn't know.
  String actionLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (action) {
      'submitted' || 'resubmitted' => l10n.excuseStepSubmitted,
      'info_requested' || 'info_required' => l10n.excuseStepInfoRequested,
      'documents_added' => l10n.excuseStepDocumentsAdded,
      'accepted' => l10n.excuseStepAccepted,
      'rejected' => l10n.excuseStepRejected,
      _ => action.replaceAll('_', ' '),
    };
  }

  /// "Parent" or "School"; empty when the API doesn't say.
  String byLabel(BuildContext context) => switch (by) {
    'parent' => context.l10n.byParent,
    '' => '',
    _ => context.l10n.bySchool,
  };
}
