import 'package:al_mahhaba_school/features/home/data/models/announcement_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/child_dashboard_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/latest_items_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/latest_result_model.dart';
import 'package:al_mahhaba_school/features/homework/data/models/homework_model.dart';

/// Talks to the school system's Home endpoints (signed in). Throws an
/// `AppException` on failure.
abstract interface class HomeRemoteDataSource {
  /// Home's summary for one child: attendance, the latest result, fees and
  /// messages. [childId] is the child's `student_id`.
  Future<ChildDashboardModel> getChildDashboard(int childId);

  /// The newest few announcements the child's parents got.
  Future<LatestItemsModel<AnnouncementModel>> getLatestAnnouncements(
    int childId,
  );

  /// The newest few homework the child was given.
  Future<LatestItemsModel<HomeworkModel>> getLatestHomework(int childId);

  /// The newest few results the child got.
  Future<LatestItemsModel<LatestResultModel>> getLatestResults(int childId);
}
