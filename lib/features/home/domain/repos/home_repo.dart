import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class HomeRepo {
  /// Everything Home shows for one child, by their `studentId`.
  Future<Result<ChildDashboardEntity>> getChildDashboard(int childId);
}
