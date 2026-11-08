import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class HomeRepo {
  /// Home's summary for one child, by their `studentId`.
  Future<Result<ChildDashboardEntity>> getChildDashboard(int childId);

  /// The newest few announcements the child's parents got.
  Future<Result<LatestItemsEntity<AnnouncementEntity>>> getLatestAnnouncements(
    int childId,
  );

  /// The newest few homework the child was given.
  Future<Result<LatestItemsEntity<HomeworkEntity>>> getLatestHomework(
    int childId,
  );

  /// The newest few results the child got.
  Future<Result<LatestItemsEntity<LatestResultEntity>>> getLatestResults(
    int childId,
  );
}
