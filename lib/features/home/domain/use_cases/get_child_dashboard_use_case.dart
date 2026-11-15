import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/repos/home_repo.dart';

/// Home's summary for one child:
/// `final result = await getChildDashboard(child.studentId);`
@lazySingleton
class GetChildDashboardUseCase {
  GetChildDashboardUseCase(this._repo);

  final HomeRepo _repo;

  Future<Result<ChildDashboardEntity>> call(int childId) =>
      _repo.getChildDashboard(childId);
}
