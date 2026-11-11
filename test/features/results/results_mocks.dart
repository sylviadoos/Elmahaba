// The Results use cases, mocked once for the bloc and page tests.
// Regenerate with `dart run build_runner build`.
// (mockito reads the annotation on an import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<GetMonthlyResultsUseCase>(),
  MockSpec<GetLatestResultUseCase>(),
  MockSpec<MarkChatReadUseCase>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/chat/domain/use_cases/mark_chat_read_use_case.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/get_latest_result_use_case.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/get_monthly_results_use_case.dart';
