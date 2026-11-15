import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_attendance_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_fees_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/message_counts_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';

/// Everything Home shows for one child, in one answer: attendance, fees,
/// messages, and the newest announcements, homework and results.
class ChildDashboardEntity extends Equatable {
  const ChildDashboardEntity({
    this.child,
    required this.attendance,
    this.latestResult,
    this.fees,
    required this.messages,
    this.announcements = const LatestItemsEntity(),
    this.homework = const LatestItemsEntity(),
    this.results = const LatestItemsEntity(),
  });

  /// null when the API leaves it out.
  final ChildEntity? child;
  final DashboardAttendanceEntity attendance;

  /// null before any result is published.
  final LatestResultEntity? latestResult;

  /// null until the school sets the child's fees.
  final DashboardFeesEntity? fees;
  final MessageCountsEntity messages;

  /// The newest few the child's parents got, newest first.
  final LatestItemsEntity<AnnouncementEntity> announcements;
  final LatestItemsEntity<HomeworkEntity> homework;
  final LatestItemsEntity<LatestResultEntity> results;

  @override
  List<Object?> get props => [
    child,
    attendance,
    latestResult,
    fees,
    messages,
    announcements,
    homework,
    results,
  ];
}
