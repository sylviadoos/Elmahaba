// The complaints use cases and data sources, mocked once for the bloc and
// repo tests. Regenerate with `dart run build_runner build`. (mockito
// reads the annotation on an import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<ComplaintsRemoteDataSource>(),
  MockSpec<GetComplaintDetailsUseCase>(),
  MockSpec<SendComplaintReplyUseCase>(),
  MockSpec<DownloadComplaintAttachmentUseCase>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/complaints/domain/use_cases/download_complaint_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/get_complaint_details_use_case.dart';
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/send_complaint_reply_use_case.dart';

import 'package:al_mahhaba_school/features/complaints/data/data_sources/complaints_remote_data_source.dart';
