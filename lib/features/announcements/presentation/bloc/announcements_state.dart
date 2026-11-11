import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/announcements/domain/entities/announcements_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';

/// Everything Announcements shows: whose, and the announcements loaded.
class AnnouncementsState extends Equatable {
  const AnnouncementsState({
    this.children = const [],
    this.isRequested = false,
    this.studentId,
    this.announcements = const BaseState.initial(),
    this.downloadingId,
    this.images = const {},
  });

  /// The parent's children.
  final List<ChildEntity> children;

  /// Whether announcements were asked for yet (the children may still be
  /// loading).
  final bool isRequested;

  /// The child whose announcements are shown; null while there's none.
  final int? studentId;

  /// The pages loaded. `moreLoading` while the next loads; an error with
  /// data when it didn't. Loading with data while it loads again (pulled
  /// down).
  final BaseState<AnnouncementsPageEntity> announcements;

  /// The file downloading now.
  final int? downloadingId;

  /// The photos shown, by attachment id. Several load at once, apart from
  /// [downloadingId].
  final ChatImages images;

  AnnouncementsPageEntity? get page => announcements.data;

  /// Where the child shown is in [children]; -1 for none.
  int get shownIndex =>
      children.indexWhere((child) => child.studentId == studentId);

  AnnouncementsState copyWith({
    List<ChildEntity>? children,
    bool? isRequested,
    int? Function()? studentId,
    BaseState<AnnouncementsPageEntity>? announcements,
    int? Function()? downloadingId,
    ChatImages? images,
  }) => AnnouncementsState(
    children: children ?? this.children,
    isRequested: isRequested ?? this.isRequested,
    studentId: studentId != null ? studentId() : this.studentId,
    announcements: announcements ?? this.announcements,
    downloadingId: downloadingId != null ? downloadingId() : this.downloadingId,
    images: images ?? this.images,
  );

  @override
  List<Object?> get props => [
    children,
    isRequested,
    studentId,
    announcements,
    downloadingId,
    images,
  ];
}
