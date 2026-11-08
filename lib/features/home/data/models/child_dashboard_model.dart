import 'package:al_mahhaba_school/features/children/data/models/child_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/dashboard_attendance_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/dashboard_fees_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/latest_result_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/message_counts_model.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';

/// The `data` of `GET v1/parent/children/{child_id}/dashboard`.
///
/// Any part may be null or missing: counts then read as 0, and the result
/// or fees as none.
class ChildDashboardModel extends ChildDashboardEntity {
  const ChildDashboardModel({
    super.child,
    required super.attendance,
    super.latestResult,
    super.fees,
    required super.messages,
  });

  factory ChildDashboardModel.fromJson(Map<String, dynamic> json) {
    // "results": { "latest": {…} or null }
    final results = json['results'] as Map<String, dynamic>?;

    return ChildDashboardModel(
      child: switch (json['child']) {
        final Map<String, dynamic> child => ChildModel.fromJson(child),
        _ => null,
      },
      attendance: DashboardAttendanceModel.fromJson(
        json['attendance'] as Map<String, dynamic>? ?? const {},
      ),
      // One without its id couldn't be opened: taken as none.
      latestResult: switch (results?['latest']) {
        final Map<String, dynamic> latest when latest['id'] is int =>
          LatestResultModel.fromJson(latest),
        _ => null,
      },
      // No payment summary: the child's fees aren't set yet.
      fees: switch (json['fees']) {
        final Map<String, dynamic> fees
            when fees['payment_summary'] is Map<String, dynamic> =>
          DashboardFeesModel.fromJson(fees),
        _ => null,
      },
      messages: MessageCountsModel.fromJson(
        json['messages'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
