import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_pdf_args.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_attachment_kind.dart';

extension ChatFileOpener on BuildContext {
  /// [attachment], downloaded to [path]: a PDF full screen here, anything
  /// else in the phone's app for it.
  Future<void> openChatFile(String path, ChatAttachmentEntity attachment) {
    if (!attachment.isPdf) return openOutside(path);
    push(
      AppRoutes.chatPdf,
      extra: ChatPdfArgs(fileName: attachment.fileName, path: path),
    );
    return Future.value();
  }

  /// The file at [path] in the phone's app for it (to save or share it);
  /// a snack bar says when there's none.
  Future<void> openOutside(String path) async {
    final result = await OpenFilex.open(path);
    if (!mounted || result.type == ResultType.done) return;
    showSnackBar(l10n.cantOpenFile, isError: true);
  }
}
