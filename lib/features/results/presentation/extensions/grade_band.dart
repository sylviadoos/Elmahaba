import 'package:flutter/material.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';

/// Where a mark stands on the school's scale, by its share of the maximum —
/// shown in color when the result's type has colors ("value and color").
enum GradeBand {
  exceeds(AppColors.gradeExceeds),
  meets(AppColors.gradeMeets),
  partiallyMeets(AppColors.gradePartiallyMeets),
  below(AppColors.gradeBelow);

  const GradeBand(this.color);

  final Color color;

  /// The chip behind the band's name: a light tint of [color].
  Color get background => color.withValues(alpha: 0.14);

  /// The band's name on its chip; dark on yellow, which is too light to
  /// read.
  Color get textColor => this == partiallyMeets ? AppColors.goldText : color;

  /// [share] is 0–1: 85% and up exceeds expectations, 65% meets them, 50%
  /// partially meets them, and less is below.
  static GradeBand of(double share) => switch (share) {
    >= 0.85 => exceeds,
    >= 0.65 => meets,
    >= 0.5 => partiallyMeets,
    _ => below,
  };

  /// A mark's bar: its band's color when the result has colors, else red.
  static Color barColor(double share, {required bool usesColors}) =>
      usesColors ? of(share).color : AppColors.actionRed;

  String label(AppLocalizations l10n) => switch (this) {
    exceeds => l10n.gradeExceeds,
    meets => l10n.gradeMeets,
    partiallyMeets => l10n.gradePartiallyMeets,
    below => l10n.gradeBelow,
  };
}
