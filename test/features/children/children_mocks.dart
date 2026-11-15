// The Children data sources and use cases, mocked once for the tests.
// Regenerate with `dart run build_runner build`.
// (mockito reads the annotation on an import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<ChildrenRemoteDataSource>(),
  MockSpec<ChildrenLocalDataSource>(),
  MockSpec<GetSavedChildrenUseCase>(),
  MockSpec<GetChildrenUseCase>(),
  MockSpec<LinkChildUseCase>(),
  MockSpec<VerifyChildLinkUseCase>(),
  MockSpec<ResendChildLinkCodeUseCase>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/children/data/data_sources/children_local_data_source.dart';
import 'package:al_mahhaba_school/features/children/data/data_sources/children_remote_data_source.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/get_children_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/get_saved_children_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/link_child_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/resend_child_link_code_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/verify_child_link_use_case.dart';
