import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';

sealed class ComplaintDetailsEvent {
  const ComplaintDetailsEvent();
}

/// Loads the complaint with this id (again, after an error or once it's
/// closed). With [refresh], the one shown stays until it arrives.
final class LoadComplaintDetailsEvent extends ComplaintDetailsEvent {
  const LoadComplaintDetailsEvent(this.complaintId, {this.refresh = false});

  final int complaintId;
  final bool refresh;
}

/// Replies on the complaint shown.
final class SendComplaintReplyEvent extends ComplaintDetailsEvent {
  const SendComplaintReplyEvent({
    required this.text,
    this.attachments = const [],
  });

  /// Empty when only files are sent.
  final String text;

  /// The paths of the files to send with it.
  final List<String> attachments;
}

/// Downloads a file of the complaint shown, for the page to open.
final class DownloadAttachmentEvent extends ComplaintDetailsEvent {
  const DownloadAttachmentEvent(this.attachment);

  final ComplaintAttachmentEntity attachment;
}
