// The complaints use cases and data sources, mocked once for the bloc and
// repo tests. Regenerate with `dart run build_runner build`. (mockito
// reads the annotation on an import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<HasNewComplaintUpdatesUseCase>(),
  MockSpec<MarkComplaintsSeenUseCase>(),
  MockSpec<ComplaintsRemoteDataSource>(),
  MockSpec<ComplaintsLocalDataSource>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/complaints/data/data_sources/complaints_local_data_source.dart';
import 'package:al_mahhaba_school/features/complaints/data/data_sources/complaints_remote_data_source.dart';
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/has_new_complaint_updates_use_case.dart';
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/mark_complaints_seen_use_case.dart';
