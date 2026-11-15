import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_due_status.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';

/// Made once per pattern and language: making one is too slow to do for
/// every card drawn.
final Map<String, DateFormat> _dateFormats = {};

/// Each homework's text direction, found once: it reads the whole text.
final Expando<TextDirection> _textDirections = Expando('homeworkDirection');

extension HomeworkDay on DateTime {
  /// "Wed 11 Nov", or "11 Nov 2025" from another year.
  String homeworkDayLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final pattern = year == DateTime.now().year ? 'EEE d MMM' : 'd MMM y';
    return _dateFormats
        .putIfAbsent('$pattern|$locale', () => DateFormat(pattern, locale))
        .format(this);
  }
}

extension HomeworkFilterLabel on HomeworkFilter {
  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      HomeworkFilter.all => l10n.filterAll,
      HomeworkFilter.dueSoon => l10n.homeworkDueSoon,
      HomeworkFilter.upcoming => l10n.homeworkUpcoming,
      HomeworkFilter.dueToday => l10n.homeworkDueTodayFilter,
      HomeworkFilter.past => l10n.homeworkPast,
      HomeworkFilter.noDueDate => l10n.homeworkNoDueDate,
    };
  }
}

extension HomeworkDisplay on HomeworkEntity {
  /// "Due Wed 11 Nov", "Due today", "Was due Mon 2 Nov" or "No due date".
  String dueLabel(BuildContext context) {
    final l10n = context.l10n;
    final day = dueDate?.homeworkDayLabel(context);
    if (day == null) return l10n.homeworkNoDueDate;
    return switch (dueStatus) {
      HomeworkDueStatus.dueToday => l10n.homeworkDueToday,
      HomeworkDueStatus.past => l10n.homeworkWasDue(day),
      HomeworkDueStatus.noDueDate => l10n.homeworkNoDueDate,
      HomeworkDueStatus.upcoming ||
      HomeworkDueStatus.unknown => l10n.homeworkDueOn(day),
    };
  }

  /// The direction its text is written in (it may not be the app's).
  TextDirection get textDirection =>
      _textDirections[this] ??= '$title $description'.textDirection;
}
