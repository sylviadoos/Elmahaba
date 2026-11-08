import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';

typedef LatestAnnouncements = LatestItemsEntity<AnnouncementEntity>;
typedef LatestHomework = LatestItemsEntity<HomeworkEntity>;
typedef LatestResults = LatestItemsEntity<LatestResultEntity>;

/// The newest announcements, homework and results of the child on Home;
/// each loads (and fails) on its own.
class LatestUpdatesState extends Equatable {
  const LatestUpdatesState({
    this.childId,
    this.announcements = const BaseState.initial(),
    this.homework = const BaseState.initial(),
    this.results = const BaseState.initial(),
  });

  /// The child shown, by `studentId`; null before the children load.
  final int? childId;
  final BaseState<LatestAnnouncements> announcements;
  final BaseState<LatestHomework> homework;
  final BaseState<LatestResults> results;

  /// A part that couldn't load, which "Try again" loads again.
  bool get hasFailure =>
      announcements.state == StateType.error ||
      homework.state == StateType.error ||
      results.state == StateType.error;

  LatestUpdatesState copyWith({
    int? childId,
    BaseState<LatestAnnouncements>? announcements,
    BaseState<LatestHomework>? homework,
    BaseState<LatestResults>? results,
  }) => LatestUpdatesState(
    childId: childId ?? this.childId,
    announcements: announcements ?? this.announcements,
    homework: homework ?? this.homework,
    results: results ?? this.results,
  );

  @override
  List<Object?> get props => [childId, announcements, homework, results];
}
