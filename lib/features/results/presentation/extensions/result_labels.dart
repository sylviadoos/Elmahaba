import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

extension ResultLabel on ResultDetailsEntity {
  /// What it's called in the filter: a month's by its month, "أكتوبر", in
  /// the app's language; a term's by its title, "نتيجة الترم الأول".
  String label(BuildContext context) {
    final period = this.period;
    if (isMonthly && period != null) {
      final locale = Localizations.localeOf(context);
      if (period.month >= 1 && period.month <= 12) {
        return DateFormat.MMMM(
          locale.toString(),
        ).format(DateTime(2000, period.month));
      }
      final name = locale.languageCode == AppConstants.arKey
          ? period.monthNameAr
          : period.monthName;
      if (name.isNotEmpty) return name;
    }
    return title.isNotEmpty ? title : context.l10n.result;
  }
}
