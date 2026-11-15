import 'package:al_mahhaba_school/features/children/data/models/child_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/announcement_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/dashboard_attendance_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/dashboard_fees_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/latest_items_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/latest_result_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/message_counts_model.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/homework/data/models/homework_model.dart';

/// The `data` of `GET v1/parent/children/{child_id}/dashboard`:
/// { "child": {…}, "attendance": {…}, "announcements": {…},
///   "homework": {…}, "results": {…}, "fees": {…}, "messages": {…} }
///
/// Any part may be null or missing: counts then read as 0, lists as empty,
/// and the result or fees as none.
class ChildDashboardModel extends ChildDashboardEntity {
  const ChildDashboardModel({
    super.child,
    required super.attendance,
    super.latestResult,
    super.fees,
    required super.messages,
    super.announcements,
    super.homework,
    super.results,
  });

  factory ChildDashboardModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> part(String key) => switch (json[key]) {
      final Map<String, dynamic> part => part,
      _ => const {},
    };
    // "results": { "latest": {…} or null, "items": […], … }
    final results = part('results');

    return ChildDashboardModel(
      child: switch (json['child']) {
        final Map<String, dynamic> child => ChildModel.fromJson(child),
        _ => null,
      },
      attendance: DashboardAttendanceModel.fromJson(part('attendance')),
      // One without its id couldn't be opened: taken as none.
      latestResult: switch (results['latest']) {
        final Map<String, dynamic> latest when latest['id'] is int =>
          LatestResultModel.fromJson(latest),
        _ => null,
      },
      fees: switch (json['fees']) {
        final Map<String, dynamic> fees => DashboardFeesModel.fromJson(fees),
        _ => null,
      },
      messages: MessageCountsModel.fromJson(part('messages')),
      announcements: LatestItemsModel.fromJson(
        part('announcements'),
        AnnouncementModel.fromJson,
      ),
      homework: LatestItemsModel.fromJson(
        part('homework'),
        HomeworkModel.fromJson,
      ),
      results: LatestItemsModel.fromJson(
        results,
        // One without its id couldn't be opened: left out.
        (result) =>
            result['id'] is int ? LatestResultModel.fromJson(result) : null,
      ),
    );
  }
}
