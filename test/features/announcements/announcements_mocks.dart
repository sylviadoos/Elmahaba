// The use cases Announcements uses (its own, and the chat's for read marks
// and files), mocked once for the bloc and page tests. Regenerate with
// `dart run build_runner build`. (mockito reads the annotation on an
// import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<GetAnnouncementsUseCase>(),
  MockSpec<MarkChatReadUseCase>(),
  MockSpec<DownloadChatAttachmentUseCase>(),
  MockSpec<PreviewChatAttachmentUseCase>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/announcements/domain/use_cases/get_announcements_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/download_chat_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/mark_chat_read_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/preview_chat_attachment_use_case.dart';
