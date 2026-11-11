import 'package:al_mahhaba_school/features/results/domain/entities/monthly_results_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

/// The forms of a child's results there are to show on Results: the
/// monthly results, the latest result, or both.
class ResultsForms {
  const ResultsForms._({this.monthly, this.latest});

  /// From what loaded (null for what didn't, or has none).
  factory ResultsForms.of({
    MonthlyResultsEntity? monthly,
    ResultDetailsEntity? latest,
  }) {
    final hasMonthly = monthly != null && monthly.hasMonths;
    // A monthly result shows with the months already.
    final latestIsMonthly =
        latest != null &&
        (monthly?.sheets.any((sheet) => sheet.id == latest.id) ?? false);
    return ResultsForms._(
      monthly: hasMonthly ? monthly : null,
      latest: latestIsMonthly ? null : latest,
    );
  }

  /// With at least one month; null when there's none to show.
  final MonthlyResultsEntity? monthly;

  /// null when there's none, or it's one of [monthly]'s.
  final ResultDetailsEntity? latest;

  bool get isEmpty => monthly == null && latest == null;

  bool get hasBoth => monthly != null && latest != null;

  /// Whether the newest month came out after [latest]; the months when
  /// either doesn't say.
  bool get monthlyIsNewer {
    final newestMonth = monthly?.certificate?.months
        .map((month) => month.publishedAt)
        .nonNulls
        .fold<DateTime?>(
          null,
          (newest, at) => newest == null || at.isAfter(newest) ? at : newest,
        );
    final latestAt = latest?.publishedAt;
    if (newestMonth == null || latestAt == null) return true;
    return !newestMonth.isBefore(latestAt);
  }
}
