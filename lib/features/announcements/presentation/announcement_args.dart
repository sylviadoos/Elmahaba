import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';

/// What `AppRoutes.announcementDetails` is opened with: the announcement
/// itself, which Home and the chat both already hold, so the page loads
/// nothing — and whose it is, so seeing it is marked for the right child.
class AnnouncementArgs extends Equatable {
  const AnnouncementArgs(this.announcement, {this.studentId});

  final AnnouncementEntity announcement;

  /// The child it's about; null for the one every page shows.
  final int? studentId;

  @override
  List<Object?> get props => [announcement, studentId];
}
