import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';

/// Several things at once, so the excuse stays on screen while documents
/// are sent, a file downloads or its pictures load.
class ExcuseDetailsState extends Equatable {
  const ExcuseDetailsState({
    this.details = const BaseState.initial(),
    this.adding = const BaseState.initial(),
    this.download = const BaseState.initial(),
    this.downloadingId,
    this.images = const {},
  });

  final BaseState<ExcuseDetailsEntity> details;

  /// The last documents sent; on success, they're in [details].
  final BaseState<void> adding;

  /// The last file opened; on success, where it was saved.
  final BaseState<String> download;

  /// The document downloading now.
  final int? downloadingId;

  /// The pictures shown in place of the documents (a photo, a PDF's first
  /// page), by document id. Several load at once, apart from
  /// [downloadingId].
  final ChatImages images;

  ExcuseDetailsState copyWith({
    BaseState<ExcuseDetailsEntity>? details,
    BaseState<void>? adding,
    BaseState<String>? download,
    int? Function()? downloadingId,
    ChatImages? images,
  }) => ExcuseDetailsState(
    details: details ?? this.details,
    adding: adding ?? this.adding,
    download: download ?? this.download,
    downloadingId: downloadingId != null ? downloadingId() : this.downloadingId,
    images: images ?? this.images,
  );

  @override
  List<Object?> get props => [details, adding, download, downloadingId, images];
}
