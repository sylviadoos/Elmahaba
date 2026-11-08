import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_reply_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/download_complaint_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/get_complaint_details_use_case.dart';
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/send_complaint_reply_use_case.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/complaint_details_event.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/complaint_details_state.dart';

/// One complaint's page: its thread, replying, and its files. The page
/// opens a downloaded file itself, hence `void`.
@injectable
class ComplaintDetailsViewModel
    extends BaseCubit<ComplaintDetailsState, ComplaintDetailsEvent, void> {
  ComplaintDetailsViewModel(
    this._getDetails,
    this._sendReply,
    this._downloadAttachment,
  ) : super(const ComplaintDetailsState());

  final GetComplaintDetailsUseCase _getDetails;
  final SendComplaintReplyUseCase _sendReply;
  final DownloadComplaintAttachmentUseCase _downloadAttachment;

  /// The reply being written. Kept when sending fails, so sending it again
  /// can't post it twice.
  String _replyUuid = const Uuid().v4();

  @override
  Future<void> doAction(ComplaintDetailsEvent event) async {
    switch (event) {
      case LoadComplaintDetailsEvent(:final complaintId, :final refresh):
        await _load(complaintId, refresh: refresh);
      case SendComplaintReplyEvent():
        await _reply(event);
      case DownloadAttachmentEvent(:final attachment):
        await _download(attachment);
    }
  }

  Future<void> _load(int complaintId, {required bool refresh}) async {
    if (state.details.state == StateType.loading) return;
    final shown = refresh ? state.details.data : null;
    if (shown == null) {
      emit(state.copyWith(details: const BaseState.loading()));
    }
    final result = await _getDetails(complaintId);
    if (isClosed) return;
    result.when(
      success: (details) =>
          emit(state.copyWith(details: BaseState.success(details))),
      failure: (exception) {
        // Refreshing: keep showing it.
        if (shown != null) return;
        emit(state.copyWith(details: BaseState.error(exception)));
      },
    );
  }

  Future<void> _reply(SendComplaintReplyEvent event) async {
    final details = state.details.data;
    if (details == null || state.reply.state == StateType.loading) return;
    emit(state.copyWith(reply: const BaseState.loading(), upload: () => null));
    final result = await _sendReply(
      details.complaint.id,
      ComplaintReplyEntity(
        text: event.text,
        attachments: event.attachments,
        clientUuid: _replyUuid,
      ),
      onProgress: _onProgress,
    );
    if (isClosed) return;
    result.when(
      success: (updated) {
        _replyUuid = const Uuid().v4();
        emit(
          state.copyWith(
            details: BaseState.success(updated),
            reply: const BaseState.success(null),
            upload: () => null,
          ),
        );
      },
      failure: (exception) => emit(
        state.copyWith(reply: BaseState.error(exception), upload: () => null),
      ),
    );
  }

  void _onProgress(int sent, int total) {
    if (isClosed || !state.upload.isStepTo(sent, total)) return;
    emit(state.copyWith(upload: () => (sent: sent, total: total)));
  }

  Future<void> _download(ComplaintAttachmentEntity attachment) async {
    final details = state.details.data;
    if (details == null || state.downloadingId != null) return;
    emit(
      state.copyWith(
        download: const BaseState.loading(),
        downloadingId: () => attachment.id,
      ),
    );
    final result = await _downloadAttachment(details.complaint.id, attachment);
    if (isClosed) return;
    result.when(
      success: (path) => emit(
        state.copyWith(
          download: BaseState.success(path),
          downloadingId: () => null,
        ),
      ),
      failure: (exception) => emit(
        state.copyWith(
          download: BaseState.error(exception),
          downloadingId: () => null,
        ),
      ),
    );
  }
}
