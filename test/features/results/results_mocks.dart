// The Results use cases and the repos they use, mocked once for the tests.
// Regenerate with `dart run build_runner build`.
// (mockito reads the annotation on an import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<GetResultsUseCase>(),
  MockSpec<MarkLatestResultReadUseCase>(),
  MockSpec<HomeRepo>(),
  MockSpec<ChatRepo>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';
import 'package:al_mahhaba_school/features/home/domain/repos/home_repo.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/get_results_use_case.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/mark_latest_result_read_use_case.dart';
