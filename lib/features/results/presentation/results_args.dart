import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

/// What `AppRoutes.results` is opened with to show one result rather than
/// the newest: the one tapped on Home.
///
/// Not compared by value on purpose: Results shows it once per tap, so
/// tapping the same result again — after picking another month in the
/// filter — shows it again, while the tab merely rebuilding doesn't.
class ResultsArgs {
  const ResultsArgs({
    required this.resultId,
    required this.title,
    required this.academicYear,
  });

  /// [result] as Home's dashboard has it.
  ResultsArgs.of(LatestResultEntity result)
    : this(
        resultId: result.id,
        title: result.title,
        academicYear: result.academicYear,
      );

  /// Its id in the dashboard.
  final int resultId;
  final String title;
  final String academicYear;

  /// The one it is among [results], or null when it isn't there (withdrawn
  /// at school since): by its id, else by its title in its school year.
  /// The dashboard and the results come from two different calls, and
  /// nothing says the two number results the same way.
  ResultDetailsEntity? pickFrom(List<ResultDetailsEntity> results) =>
      results.where((result) => result.id == resultId).firstOrNull ??
      results
          .where(
            (result) =>
                result.title.trim() == title.trim() &&
                result.academicYear == academicYear,
          )
          .firstOrNull;
}
