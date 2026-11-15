import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

extension SchoolOrder on List<ResultDetailsEntity> {
  /// These in the school year's order, as the parent reads them: October,
  /// November, the first term, March, April, the second term… A month goes
  /// by its month; a term, which has none, by when it was published — after
  /// the months before it. One that says neither, last.
  List<ResultDetailsEntity> inSchoolOrder() {
    final epochEnd = DateTime.utc(9999);
    return [...this]..sort(
      (a, b) =>
          (a._schoolDate ?? epochEnd).compareTo(b._schoolDate ?? epochEnd),
    );
  }
}

extension on ResultDetailsEntity {
  /// Where it falls in the year: a month's, the end of its month (its
  /// marks are in by then); any other's, when it was published.
  DateTime? get _schoolDate {
    final period = this.period;
    final year = period?.year;
    if (isMonthly &&
        period != null &&
        year != null &&
        period.month >= 1 &&
        period.month <= 12) {
      // The first moment of the next month.
      return DateTime.utc(year, period.month + 1);
    }
    return publishedAt;
  }
}
