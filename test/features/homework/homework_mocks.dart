// The use cases Homework uses (its own, and the chat's for read marks and
// files), mocked once for the bloc tests. Regenerate with
// `dart run build_runner build`. (mockito reads the annotation on an
// import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<GetHomeworkUseCase>(),
  MockSpec<FindHomeworkUseCase>(),
  MockSpec<HomeworkRepo>(),
  MockSpec<MarkChatReadUseCase>(),
  MockSpec<DownloadChatAttachmentUseCase>(),
  MockSpec<PreviewChatAttachmentUseCase>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/chat/domain/use_cases/download_chat_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/mark_chat_read_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/preview_chat_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/homework/domain/repos/homework_repo.dart';
import 'package:al_mahhaba_school/features/homework/domain/use_cases/find_homework_use_case.dart';
import 'package:al_mahhaba_school/features/homework/domain/use_cases/get_homework_use_case.dart';
