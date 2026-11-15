// The excuse page's use cases, mocked once for the view model tests.
// Regenerate with `dart run build_runner build`. (mockito reads the
// annotation on an import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<GetExcuseDetailsUseCase>(),
  MockSpec<AddExcuseDocumentsUseCase>(),
  MockSpec<DownloadExcuseDocumentUseCase>(),
  MockSpec<PreviewExcuseDocumentUseCase>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/excuses/domain/use_cases/add_excuse_documents_use_case.dart';
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/download_excuse_document_use_case.dart';
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/get_excuse_details_use_case.dart';
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/preview_excuse_document_use_case.dart';
