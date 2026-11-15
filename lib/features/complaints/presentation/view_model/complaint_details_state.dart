import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_details_entity.dart';

/// Three things at once, so the thread stays on screen while a reply is
/// sent or a file downloads.
class ComplaintDetailsState extends Equatable {
  const ComplaintDetailsState({
    this.details = const BaseState.initial(),
    this.reply = const BaseState.initial(),
    this.upload,
    this.download = const BaseState.initial(),
    this.downloadingId,
  });

  /// The complaint and its thread.
  final BaseState<ComplaintDetailsEntity> details;

  /// The last reply sent; on success it's in [details].
  final BaseState<void> reply;

  /// How far the reply and its files got, while it's sent.
  final UploadProgress? upload;

  /// The last file opened; on success, where it was saved.
  final BaseState<String> download;

  /// The attachment downloading now.
  final int? downloadingId;

  ComplaintDetailsState copyWith({
    BaseState<ComplaintDetailsEntity>? details,
    BaseState<void>? reply,
    UploadProgress? Function()? upload,
    BaseState<String>? download,
    int? Function()? downloadingId,
  }) => ComplaintDetailsState(
    details: details ?? this.details,
    reply: reply ?? this.reply,
    upload: upload != null ? upload() : this.upload,
    download: download ?? this.download,
    downloadingId: downloadingId != null ? downloadingId() : this.downloadingId,
  );

  @override
  List<Object?> get props => [details, reply, upload, download, downloadingId];
}
