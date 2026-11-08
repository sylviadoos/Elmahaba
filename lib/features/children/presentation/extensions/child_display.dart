import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_parent_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/labeled_value_entity.dart';

extension ChildDisplay on ChildEntity {
  /// The Arabic name in Arabic (when the school has one), else the English.
  String displayName(BuildContext context) =>
      Localizations.localeOf(context).languageCode == AppConstants.arKey &&
          nameAr.isNotEmpty
      ? nameAr
      : name;

  /// The first word of [displayName], for tight spots.
  String firstName(BuildContext context) =>
      displayName(context).split(' ').first;

  /// e.g. "Second Primary · A".
  String get gradeAndClass =>
      [grade, className].where((part) => part.isNotEmpty).join(' · ');

  /// The last digits of the national ID: "••••0923" → "0923".
  String get nationalIdTail => nationalId.replaceAll(RegExp(r'\D'), '');

  /// e.g. "Second Primary · A · ID ••••0923", under the name in lists.
  String summary(BuildContext context) {
    final idTail = nationalIdTail;
    return [
      gradeAndClass,
      if (idTail.isNotEmpty) context.l10n.childIdTail(idTail),
    ].where((part) => part.isNotEmpty).join(' · ');
  }
}

extension LabeledValueDisplay on LabeledValueEntity {
  /// The Arabic name in Arabic (when the school has one), else the English.
  String localized(BuildContext context) =>
      Localizations.localeOf(context).languageCode == AppConstants.arKey &&
          labelAr.isNotEmpty
      ? labelAr
      : label;
}

extension ChildParentDisplay on ChildParentEntity {
  /// The Arabic name in Arabic (when the school has one), else the other.
  String displayName(BuildContext context) =>
      Localizations.localeOf(context).languageCode == AppConstants.arKey &&
          nameAr.isNotEmpty
      ? nameAr
      : name.isEmpty
      ? nameAr
      : name;
}

extension ChildrenDisplay on List<ChildEntity> {
  /// Their first names: "Omar, Lina".
  String firstNames(BuildContext context) => map(
    (child) => child.firstName(context),
  ).join(context.isRtl ? '، ' : ', ');
}
