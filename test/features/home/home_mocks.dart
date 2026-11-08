// The Home use cases, mocked once for the bloc and widget tests.
// Regenerate with `dart run build_runner build`.
// (mockito reads the annotation on an import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<GetLatestAnnouncementsUseCase>(),
  MockSpec<GetLatestHomeworkUseCase>(),
  MockSpec<GetLatestResultsUseCase>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/home/domain/use_cases/get_latest_announcements_use_case.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_latest_homework_use_case.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_latest_results_use_case.dart';
