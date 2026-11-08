import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_attendance_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_fees_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/message_counts_entity.dart';

/// Home's summary for one child: attendance, the latest result, fees and
/// messages.
class ChildDashboardEntity extends Equatable {
  const ChildDashboardEntity({
    this.child,
    required this.attendance,
    this.latestResult,
    this.fees,
    required this.messages,
  });

  /// null when the API leaves it out.
  final ChildEntity? child;
  final DashboardAttendanceEntity attendance;

  /// null before any result is published.
  final LatestResultEntity? latestResult;

  /// null until the school sets the child's fees.
  final DashboardFeesEntity? fees;
  final MessageCountsEntity messages;

  @override
  List<Object?> get props => [child, attendance, latestResult, fees, messages];
}
