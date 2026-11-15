import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

final Map<String, DateFormat> _dateFormats = {};

extension LatestDay on DateTime {
  /// When it came, short: "Today", "Yesterday", "5 Nov", or "5 Nov 2025"
  /// from another year. In the phone's time zone.
  String latestDayLabel(BuildContext context) {
    final l10n = context.l10n;
    final local = toLocal();
    final now = DateTime.now();
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(local.year, local.month, local.day)).inDays;
    if (days == 0) return l10n.today;
    if (days == 1) return l10n.yesterday;
    final locale = Localizations.localeOf(context).toString();
    final pattern = local.year == now.year ? 'd MMM' : 'd MMM y';
    return _dateFormats
        .putIfAbsent('$pattern|$locale', () => DateFormat(pattern, locale))
        .format(local);
  }
}
