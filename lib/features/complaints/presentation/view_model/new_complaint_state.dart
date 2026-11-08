import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_category_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';

/// Two things at once, so the categories stay on screen while sending.
class NewComplaintState extends Equatable {
  const NewComplaintState({
    this.categories = const BaseState.initial(),
    this.sending = const BaseState.initial(),
    this.upload,
  });

  /// The categories to pick the complaint's from.
  final BaseState<List<ComplaintCategoryEntity>> categories;

  /// The last send; on success, the complaint as the school filed it.
  final BaseState<ComplaintEntity> sending;

  /// How far the complaint and its files got, while it's sent.
  final UploadProgress? upload;

  NewComplaintState copyWith({
    BaseState<List<ComplaintCategoryEntity>>? categories,
    BaseState<ComplaintEntity>? sending,
    UploadProgress? Function()? upload,
  }) => NewComplaintState(
    categories: categories ?? this.categories,
    sending: sending ?? this.sending,
    upload: upload != null ? upload() : this.upload,
  );

  @override
  List<Object?> get props => [categories, sending, upload];
}
