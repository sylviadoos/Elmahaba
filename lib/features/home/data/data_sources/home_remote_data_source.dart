import 'package:al_mahhaba_school/features/home/data/models/child_dashboard_model.dart';

/// Talks to the school system's Home endpoint (signed in). Throws an
/// `AppException` on failure.
abstract interface class HomeRemoteDataSource {
  /// Everything Home shows for one child: attendance, fees, messages, and
  /// the newest announcements, homework and results. [childId] is the
  /// child's `student_id`.
  Future<ChildDashboardModel> getChildDashboard(int childId);
}
