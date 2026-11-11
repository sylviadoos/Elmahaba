// The chat use cases, mocked once for the bloc tests. Regenerate with
// `dart run build_runner build`. (mockito reads the annotation on an
// import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<GetChatUseCase>(),
  MockSpec<GetCachedChatUseCase>(),
  MockSpec<SendChatMessageUseCase>(),
  MockSpec<MarkChatReadUseCase>(),
  MockSpec<DownloadChatAttachmentUseCase>(),
  MockSpec<GetChatUnreadCountUseCase>(),
  MockSpec<PreviewChatAttachmentUseCase>(),
  MockSpec<WatchChatReadsUseCase>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/chat/domain/use_cases/download_chat_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/get_cached_chat_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/get_chat_unread_count_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/get_chat_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/mark_chat_read_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/preview_chat_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/send_chat_message_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/watch_chat_reads_use_case.dart';
